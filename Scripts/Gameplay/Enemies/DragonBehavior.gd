extends AnimatedSprite2D

var state = IDLE
var hp = 2
var hasDied = false

@onready var anticipation_1 = $Anticipation1
@onready var anticipation_2 = $Anticipation2
@onready var anticipation_3 = $Anticipation3
@onready var fire = $Fire
@onready var kachin = $Kachin
@onready var hitbox = $enemyHitbox/CollisionShape2D
@onready var hitbox2 = $enemyHitbox2/CollisionShape2D
@onready var hitEffect = $HitEffect

var playerInsideArea = false
@onready var player = get_parent().get_node("PlayerObject")

var hitboxtimer = 5
var hitbox2timer = 5
var gotParried = false
var uniqueParried = false
var anti2Played = false
var anti3Played = false
var prepareSecondAttack = false
var gotParriedAgain = false
enum{
	IDLE,
	ANTICIPATION,
	ANTICIPATIONTWO,
	ATTACK,
	ATTACKTWO,
	PARRIED
}

func _ready():
	Conductor.beatSignal.connect(playIdle)

func _process(delta):
	if hp <= 0 and !hasDied:
		if (player != null):
			#offset.y = 20
			if (CharaHandler.idealParries != player.parries):
				player.parries += 1
				player.createParryText("+1 trick!")
		$explosion.play()
		hitbox.set_deferred("disabled", true)
		hitbox2.set_deferred("disabled", true)
		$enemyHurtbox/CollisionShape2D.set_deferred("disabled", true)
		hitEffect.modulate.a = 0
		play("Death")
		#visible = false
		hasDied = true
	if !hasDied:
		if hitEffect.modulate.a > 0:
			hitEffect.modulate.a -= (0.05 * 60) * delta
		
		if (get_animation() != "Attack1"):
			if (player.position.x < position.x):
				scale.x = 1
			if (player.position.x >= position.x):
				scale.x = -1

		if (playerInsideArea):
			if !(gotParried or gotParriedAgain):
				playerInsideArea = false
				player.die = true

		if (gotParried):
			hitboxtimer = 5
			hitbox.set_deferred("disabled", true)

		if (gotParriedAgain):
			$enemyHurtbox/CollisionShape2D.set_deferred("disabled", true)
			hitbox2timer = 5
			hitbox2.set_deferred("disabled", true)

		if (prepareSecondAttack):
			hitbox2timer = 5

		if (state == ANTICIPATION):
			match(Conductor.beatCounter):
				5:
					frame = 0
				6:
					if (!anti2Played):
						play("Anticipation")
						frame = 2
						anti2Played = true
						if (!Conductor.stopSoundEffects):
							anticipation_2.play()
				7:
					if (!gotParried):
						play("Attack1")
					if (!anti3Played):
						anti2Played = false
						anti3Played = true
						hitbox.set_deferred("disabled", false)
						if (!Conductor.stopSoundEffects):
							fire.play()
				8:
					if (prepareSecondAttack):
						play("Anticipation2")
						anti3Played = false
						if (!anti2Played):
							anti2Played = true
							anticipation_2.play()
				1:
					if (prepareSecondAttack):
						play("Attack2")
						if (!anti3Played):
							anti3Played = true
							hitbox2.set_deferred("disabled", false)
							if (!Conductor.stopSoundEffects):
								fire.play()
					if gotParriedAgain:
						play("Parried")
		if (hitbox.disabled == false):
			if hitboxtimer > 0:
				hitboxtimer -= (1*60)*delta
			else:
				hitbox.set_deferred("disabled", true)
				hitboxtimer = 5

		if (hitbox2.disabled == false):
			if hitbox2timer > 0:
				hitbox2timer -= (1*60)*delta
			else:
				hitbox2.set_deferred("disabled", true)
				hitbox2timer = 5

		if (Conductor.beatCounter == 5):
			if (state != ANTICIPATION):
				gotParried = false
				if (!Conductor.stopSoundEffects):
					anticipation_1.play()
				state = ANTICIPATION
				set_animation("Anticipation")

func playIdle():
	if (state == IDLE and !hasDied):
		gotParried = false
		gotParriedAgain = false
		$enemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
		if prepareSecondAttack:
			prepareSecondAttack = false
		play("Idle")

func _on_animation_finished():
	if get_animation() == "Attack1" or get_animation() == "Attack2":
		state = IDLE
		anti2Played = false
		anti3Played = false
	if (get_animation() == "Parried"):
		state = IDLE
		anti2Played = false
		anti3Played = false
		gotParried = false
		gotParriedAgain = false
		prepareSecondAttack = false
		
#enemy bird behavior
func _on_enemy_hitbox_body_entered(body):
	if (!hitbox.disabled or !hitbox2.disabled):
		if body.name == "PlayerObject":
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

				if (!prepareSecondAttack):
					var hitStopLength = 2.4 / 4.0 * seconds_per_beat
					
					body.hitStop(0.01, hitStopLength)
					prepareSecondAttack = true
				else:
					var hitStopLength = 5.4 / 4.0 * seconds_per_beat
					
					body.hitStop(0.05, hitStopLength)
					gotParriedAgain = true
					if (!uniqueParried):
						body.createParryText()
						body.parries += 1
						uniqueParried = true
					play("Parried")
				gotParried = true
				anti2Played = false
				anti3Played = false
	#			play("Parried")


func _on_enemy_hurtbox_body_entered(body):
	if (body.name == "PlayerObject"):
		playerInsideArea = true


func _on_enemy_hurtbox_body_exited(body):
	if (body.name == "PlayerObject"):
		playerInsideArea = false

func _on_enemy_real_hurtbox_area_entered(area):
	if area.name == "PunchHitbox" and !hasDied:
		hitEffect.modulate.a = 1
		if area.name != "BulletCol":
			player.mayHitSfx.play()
		hp -= 1
		player.velocity.x -= (25 * player.facing)
	elif (area.name == "AirRollHitbox" or area.name == "BulletCol") and !hasDied:
		hitbox.set_deferred("disabled", true)
		hitbox2.set_deferred("disabled", true)
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		player.mayHitSfx.play()
		#i know this code is shit leave me alone
		player.oldVelocityVertical = -286 * Conductor.singleFramephysicsSpeedMultiplier
		player.oldVelocity = (player.playerSprite.scale.x * ((6 + player.dashSpeed * 53) * Conductor.singleFramephysicsSpeedMultiplier))
		hp -= 3
