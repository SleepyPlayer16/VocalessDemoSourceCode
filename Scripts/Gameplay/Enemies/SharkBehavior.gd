extends CharacterBody2D

var hp = 2
var hasDied = false

@export var jumpPower = -400
@export var type = 1
@export var gravity = 16

@onready var player = get_parent().get_node("PlayerObject")
@onready var spr = $Shark
@onready var sfxJump = $Jump
@onready var sfxSplash = $Splash
@onready var sfxBite = $Bite
@onready var attackHitBox = $Area2D/CollisionShape2D
@onready var hitEffect = $Shark/HitEffect

var posy
var beat = 1
var actualbeat = 1
var event = 1
var timer = 60
var cycle = 0
var bite_cycle = 1
var process_code = true

var vsp = 0
var play_sound = false

var hitboxtimer = 5
var gotParried = false
var uniqueParried = false
var anti2Played = false
var anti3Played = false

func _ready():
	posy  = position.y
	beat = Conductor.beatCounter
	
func _physics_process(delta: float) -> void:
	if hp <= 0 and !hasDied:
		if (player != null):
			#offset.y = 20
			if (CharaHandler.idealParries != player.parries):
				player.parries += 1
				player.createParryText("+1 trick!")
		$explosion.play()
		attackHitBox.set_deferred("disabled", true)
		hitEffect.modulate.a = 0
		spr.play("Death")
		spr.offset = Vector2(45, 85)
		#visible = false
		hasDied = true
	if !hasDied:
		if hitEffect.modulate.a > 0:
			hitEffect.modulate.a -= (0.05 * 60) * delta
	if (!hasDied):
		beat = Conductor.beatCounter
		if type == 1:
			if beat == 4 and cycle == 0:
				cycle = 1
				bite_cycle = 0
				velocity.y = (jumpPower*60)*delta
				spr.play("AttackCharge")
				sfxJump.play()
				sfxSplash.play()

			if beat == 5 and bite_cycle == 0:
				spr.play("Bite")
				attackHitBox.set_deferred("disabled", false)
				bite_cycle = 1
				sfxBite.play()
	#			soundHandler("res://sound_effect stuff/retro_die_02.ogg")
		else:
			if beat == 8 and cycle == 0:
				cycle = 1
				bite_cycle = 0
				spr.play("AttackCharge")
				sfxJump.play()
				sfxSplash.play()
				velocity.y = (jumpPower*60)*delta
			if beat == 1 and bite_cycle == 0:
				bite_cycle = 1
				spr.play("Bite")
				attackHitBox.set_deferred("disabled", false)
				sfxBite.play()
		if cycle == 1:
			velocity.y += gravity+2
			
		if spr.get_animation() == "Idle" or spr.get_animation() == "Parried":
			velocity.y = 0
			position.y = lerp(float(position.y),float(posy), (0.1*60)*delta)
		move_and_slide()


func _on_shark_animation_finished():
	if spr.get_animation() == "Bite":
		cycle = 0
		attackHitBox.set_deferred("disabled", true)
		sfxSplash.play()
		if gotParried:
			pass
		else:
			spr.play("Idle")
	if spr.get_animation() == "Parried":
		gotParried = false
		spr.play("Idle")


func _on_area_2d_body_entered(body):
	if (!attackHitBox.disabled and body.name == "PlayerObject"):
		if (body.stateMachine.state != body.stateMachine.states.parry):
			body.die = true
		else:
			if body.position.x < position.x:
				if body.facing == -1:
					body.facing = 1
					body.get_node("Smoothing2D/"+body.currentCharacter).scale.x = body.facing
			else:
				if body.facing == 1:
					body.facing = -1
					body.get_node("Smoothing2D/"+body.currentCharacter).scale.x = body.facing
			body.parrySfx.play()
			body.spawn_parryFX(body.facing)
			body.cam.zoom.x = 2.35
			body.cam.zoom.y = 2.35
			body.shake(0.2, 1)
			body.speedlines.show()
			
			var beats_per_second = Conductor.bpm / 60.0
			var seconds_per_beat = 0.7 / beats_per_second

			var hitStopLength = 5.4 / 4.0 * seconds_per_beat
			
			body.hitStop(0.05, hitStopLength)
			
			if (!uniqueParried):
				body.createParryText()
				body.parries += 1
				uniqueParried = true
			gotParried = true
			cycle = 0
			attackHitBox.set_deferred("disabled", true)
			anti2Played = false
			anti3Played = false
			spr.play("Parried")



func _on_enemy_hurtbox_area_entered(area):
	if area.name == "PunchHitbox" and !hasDied:
		hitEffect.modulate.a = 1
		if area.name != "BulletCol":
			player.mayHitSfx.play()
		hp -= 1
		player.velocity.x -= (25 * player.facing)
	elif (area.name == "AirRollHitbox" or area.name == "BulletCol") and !hasDied:
		attackHitBox.set_deferred("disabled", true)
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		player.mayHitSfx.play()
		#i know this code is shit leave me alone
		player.oldVelocityVertical = -286 * Conductor.singleFramephysicsSpeedMultiplier
		player.oldVelocity = (player.playerSprite.scale.x * ((6 + player.dashSpeed * 53) * Conductor.singleFramephysicsSpeedMultiplier))
		hp -= 3
