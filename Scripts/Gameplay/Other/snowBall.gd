extends Node2D

var direction = 1
@onready var col = $SnowBallArea/CollisionShape2D
@onready var particles = $CPUParticles2D
@onready var spr = $AnimatedSprite2D
@onready var speedlines = $Speedlines
@onready var breakSFX = $Break
@onready var player = get_tree().current_scene.get_node("PlayerObject")

var timer = 2
var speedo = 2.5
var timesPressed = 1
var playerTrapped = false
var destroyed = false
var deathTimer = 1
var hitNote = false
var missedNote = false
var coolDown = 0
var beat_time = 85
var decreaseFactor = 0.0
var goingDown = false
var inputs = [
	"jump", 
	"stomp", 
	"dash",
	"customAction",
	"parry",
]

@onready var hitNoteSound = $Metronome
@onready var missNoteSound = $Trip

func _ready():
	Conductor.just_Signal.connect(GoodToGo)
	Conductor.miss_Signal.connect(youFool)
	decreaseFactor = Conductor.bpm * 4 #adapts to song's bpm

func _process(delta):
	coolDown = max(0, coolDown - delta)

	if !destroyed:
		if playerTrapped:
			player.global_position = global_position
		if speedo >= 5:
			spr.play("playerTrapped_size2")
			speedlines.visible = true
		else:
			if playerTrapped:
				spr.play("playerTrapped_size1")
			else:
				spr.play("default")
			speedlines.visible = false
		timer -= 60*delta
		if timer <= 0 and spr.scale.x != 1:
			spr.scale.x = 1
			spr.scale.y = 1

			position.x += 20
			#position.x += 20*direction
		#if playerTrapped:
			#if speedo < 2:
				#speedo = 2
			#for action in inputs:
				#if (Input.is_action_just_pressed(action)) and coolDown <= 0:
					#coolDown = beat_time / decreaseFactor
					#if player != null:
						#player.stateMachine.cooldown = beat_time / decreaseFactor
					#if player.hitNote:
						#timesPressed+=1
						#speedo += 0.4*timesPressed
						#hitNote = false
					#else:
						#if timesPressed != 1:
							#timesPressed-=1
						#if speedo > 2:
							#speedo -= 0.4*timesPressed
							#missedNote = false

		position.x += ((speedo*60)*delta)
		if (goingDown):
			position.y += ((speedo*60)*delta)
	else:
		deathTimer -= (delta)
		if deathTimer <= 0:
			queue_free()

func _input(event):
	if playerTrapped and (event is InputEventKey):
		if speedo < 2:
			speedo = 2
		for action in inputs:
			if (event.is_action_pressed(action)) and coolDown <= 0:
				coolDown = beat_time / decreaseFactor
				if player != null:
					player.stateMachine.cooldown = beat_time / decreaseFactor
				if player.stateMachine.hitNote:
					hitNoteSound.play()
					player.spawn_judgement(0)
					timesPressed+=1
					speedo += 0.4*timesPressed
					hitNote = false
				else:
					if timesPressed != 1:
						timesPressed-=1
					if speedo > 2:
						speedo -= 0.4*timesPressed
						missNoteSound.play()
						player.spawn_judgement(1)
						missedNote = false

func _on_snow_ball_area_body_entered(body):
	if (!destroyed):
		if body.name == "PlayerObject":
			if body.stateMachine.state != body.stateMachine.states.trip:
				playerTrapped = true
				player = body
				if !body.inSnowBall:
					body.inSnowBall = true
		if body.name == "BigIcePillar":
			breakSFX.play()
			destroyed = true
			if speedo >= 6:
				var beats_per_second = Conductor.bpm / 60.0
				var seconds_per_beat = 0.7 / beats_per_second
				var hitStopLength = 5.4 / 4.0 * seconds_per_beat
				body.destroyed = true
				body.hitStop(0.05, hitStopLength)
			col.set_deferred("disabled", true)
			if playerTrapped:
				playerShit(true)
			speedlines.visible = false
			particles.emitting = true
			spr.visible = false
		else:
			if body.name != "PlayerObject":
				if playerTrapped:
					playerShit(false)
				breakSFX.play()
				destroyed = true
				speedlines.visible = false
				particles.emitting = true
				spr.visible = false

func _on_snow_ball_area_area_entered(area):
	if area.name == "SnowballDirChange":
		if (!goingDown):
			goingDown = true
		else:
			goingDown = false
	if area.name == "SnowBallArea":
		if !destroyed and playerTrapped:
			if !area.get_parent().playerTrapped:
				area.get_parent().destroyed = true
				area.get_parent().breakSFX.play()
				#print("ayowhat")
				area.get_parent().col.set_deferred("disabled", true)
				area.get_parent().particles.emitting = true
				area.get_parent().spr.visible = false
				area.get_parent().speedlines.visible = false

func GoodToGo():
	missedNote = false
	hitNote = true

func youFool():
	hitNote = false
	missedNote = true

func playerShit(juice):
	playerTrapped = false
	player.position.y -= 20
	player.velocity.y -= 20 * Conductor.singleFramephysicsSpeedMultiplier
	player.jumpFromSnowBall = true
	player.inSnowBall = false
	player.playerSprite.visible = true
	player.facing = 1
	player.tripSfx.play()
	player.stateMachine.set_state(player.stateMachine.states.trip)
	if juice and speedo >= 6:
		player.cam.zoom.x = 3
		player.cam.zoom.y = 3
		var beats_per_second = Conductor.bpm / 60.0
		var seconds_per_beat = 0.7 / beats_per_second
		var hitStopLength = 5.4 / 4.0 * seconds_per_beat
		player.hitStop(0.05, hitStopLength)
		player.shake(0.2, 1)
		player.speedlines.show()
		player.parrySfx.play()


