extends AnimatedSprite2D

var state = IDLE
var hitboxtimer = 5
var gotParried = false
var uniqueParried = false
var anti2Played = false
var anti3Played = false
var hitStopActive = false
var hitStopTimer = 0
var hitStopDecreaseSpeed = 0
var confused = false
var currentBeat = 0
var playerInsideArea = false
var hasDied = false
var hp = 2

@onready var anticipation_1 = $Anticipation1
@onready var anticipation_2 = $Anticipation2
@onready var anticipation_3 = $Anticipation3
@onready var fire = $Fire
@onready var kachin = $Kachin
@onready var hitbox = $enemyHitbox/CollisionShape2D
@onready var hitEffect = $HitEffect
@onready var player = get_parent().get_node("PlayerObject")
@onready var parryMark = preload("res://Objects/FX/EnemyParryMark.tscn")

enum{
	IDLE,
	ANTICIPATION,
	ATTACK,
	PARRIED
}

func _ready():
	Conductor.beatSignal.connect(playIdle)
	Conductor.beatSignalBPM.connect(beatCounter)

func _process(delta):
	if hp <= 0 and !hasDied:
		if (player != null):
			offset.y = 20
			if (CharaHandler.idealParries != player.parries):
				player.parries += 1
				player.createParryText("+1 trick!")
		$explosion.play()
		hitEffect.modulate.a = 0
		play("Death")
		#visible = false
		hasDied = true
	if !hasDied:
		if hitEffect.modulate.a > 0:
			hitEffect.modulate.a -= (0.05 * 60) * delta
		freezeManage(delta)
		if !player.phantomDashOnCoolDown and state != ATTACK:
			if (player.position.x < position.x):
				scale.x = 1
			if (player.position.x >= position.x):
				scale.x = -1
		
		if (playerInsideArea):
			if (!gotParried):
				playerInsideArea = false
				if (player.phantomTime <= 0):
					player.die = true
				else:
					player.spawn_phantom(42)
					#parryMarkFX()
					confused = true
		
		if (gotParried):
			hitboxtimer = 5
			hitbox.set_deferred("disabled", true)

		if (state == ANTICIPATION):
			match(Conductor.beatCounter):
				5:
					frame = 0
				6:
					frame = 1
					if (!anti2Played):
						anti2Played = true
						if (!Conductor.stopSoundEffects):
							anticipation_2.play()
				7:
					frame = 2
					if (!anti3Played):
						anti3Played = true
						if (!Conductor.stopSoundEffects):
							anticipation_3.play()
				8:
					frame = 3
					
		if (state == ANTICIPATION and Conductor.beatCounter == 8):
			gotParried = false
			hitbox.set_deferred("disabled", false)
			frame = 0
			if (!Conductor.stopSoundEffects):
				fire.play()
				kachin.play()
			state = ATTACK
			play("FireBreath")
			
		if (hitbox.disabled == false):
			if hitboxtimer > 0:
				hitboxtimer -= (1*60)*delta
			else:
				hitbox.set_deferred("disabled", true)
				hitboxtimer = 5

		if (Conductor.beatCounter == 5):
			if (state != ANTICIPATION):
				gotParried = false
				if (!Conductor.stopSoundEffects):
					anticipation_1.play()
				state = ANTICIPATION
				set_animation("Anticipation")

func beatCounter():
	if confused:
		set_animation("Anticipation")
		anti2Played = false
		anti3Played = false
		state = ANTICIPATION
		currentBeat = 7
		confused = false
	else:
		currentBeat =  Conductor.beatCounter

func playIdle():
	if (state == IDLE and !hasDied):
		play("Idle")

func _on_animation_finished():
	if get_animation() == "FireBreath":
		state = IDLE
		currentBeat = 1
		anti2Played = false
		anti3Played = false
	if (get_animation() == "Parried"):
		state = IDLE
		anti2Played = false
		anti3Played = false
		gotParried = false
		currentBeat = 1
#enemy bird behavior
func _on_enemy_hitbox_body_entered(body):
	if (!hitbox.disabled and body.name == "PlayerObject"):
		
		if (body.stateMachine.state != body.stateMachine.states.parry):
			if (body.phantomTime <= 0):
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
			
			body.parriedEnemy(false)
			var beats_per_second = Conductor.bpm / 60.0
			var seconds_per_beat = 0.7 / beats_per_second
			var hitStopLength = 5.4 / 4.0 * seconds_per_beat
			hitStop(0.05, hitStopLength)

			if (!uniqueParried):
				body.createParryText("+1 parry!")
				body.parries += 1
				uniqueParried = true
			gotParried = true
			anti2Played = false
			anti3Played = false
			play("Parried")
			
func parryMarkFX():
	var id = parryMark.instantiate()
	add_child(id)
			
func freezeManage(delta):
	if (hitStopTimer > 0):
		speed_scale = 0
		hitStopTimer -= (hitStopDecreaseSpeed * 60) * delta
	else:
		speed_scale = 2
		hitStopTimer = 0
		hitStopDecreaseSpeed = 0
		hitStopActive = false

func hitStop(timeScale, duration):
	hitStopActive = true
	hitStopTimer = duration
	hitStopDecreaseSpeed = timeScale

func _on_enemy_hurtbox_body_entered(body):
		if (body.name == "PlayerObject"):
			playerInsideArea = true

func _on_enemy_hurtbox_body_exited(body):
		if (body.name == "PlayerObject"):
			playerInsideArea = false

func _on_enemy_hitbox_area_entered(area):

	if area.name == "PhantomParryArea":
		player.parriedEnemy(false)
		var beats_per_second = Conductor.bpm / 60.0
		var seconds_per_beat = 0.7 / beats_per_second
		var hitStopLength = 5.4 / 4.0 * seconds_per_beat
		hitStop(0.05, hitStopLength)

		if (!uniqueParried):
			player.createParryText()
			player.parries += 1
			uniqueParried = true
		gotParried = true
		anti2Played = false
		anti3Played = false
		play("Parried")

func _on_enemy_hurtbox_area_entered(area):
	if area.name == "PunchHitbox" and !hasDied:
		hitEffect.modulate.a = 1
		if area.name != "BulletCol":
			player.mayHitSfx.play()
		hp -= 1
		player.velocity.x -= (25 * player.facing)
	elif (area.name == "AirRollHitbox" or area.name == "BulletCol") and !hasDied:
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		hitbox.set_deferred("disabled", true)
		player.mayHitSfx.play()
		#i know this code is shit leave me alone
		player.oldVelocityVertical = -286 * Conductor.singleFramephysicsSpeedMultiplier
		player.oldVelocity = (player.playerSprite.scale.x * ((6 + player.dashSpeed * 53) * Conductor.singleFramephysicsSpeedMultiplier))
		hp -= 3
