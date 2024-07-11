extends AnimatedSprite2D

var beat = 1
var actualbeat = 1
var event = 1
var timer = 60
var cycle = 0
var type = 1
var fallPlayed = false
var attackPlayed = false
var gotParried = false

var hp = 2
var hasDied = false
var playedDeathSfx = false
@onready var hitEffect = $HitEffect

@onready var sfxJump = $Jump
@onready var sfxJump2 = $Jump2
@onready var sfxFall = $Fall
@onready var sfxShockWave = $Shockwave
@onready var player = get_parent().get_node("PlayerObject")
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var sfxKill = $Kill

func _process(_delta):
	if hp <= 0 and !hasDied:
		if (player != null):
			#offset.y = 20
			if (CharaHandler.idealParries != player.parries):
				player.parries += 1
				player.createParryText("+1 trick!")
		hitbox.set_deferred("disabled", true)

		$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", true)
		play("Parried")
		#visible = false
		hasDied = true
	if (hasDied and get_animation() == "Parried"):
		if hitEffect.modulate.a > 0:
			hitEffect.modulate.a -= (0.05 * 60) * _delta
		if frame > 2:
			if !playedDeathSfx:
				playedDeathSfx = true
				sfxKill.play()

	if (!hasDied):
		if hitEffect.modulate.a > 0:
			hitEffect.modulate.a -= (0.05 * 60) * _delta
		
		if (get_animation() == "Jump" and frame > 0):
			$StaticBody2D2/CollisionShape2D.set_deferred("disabled", false)
			$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
		else:
			$StaticBody2D2/CollisionShape2D.set_deferred("disabled", true)
			$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", true)

		if !gotParried:
			if (get_animation() != "Attack"):
				if (player.position.x < position.x):
					scale.x = 1
				if (player.position.x >= position.x):
					scale.x = -1
			
			beat = Conductor.beatCounter
			if ( get_animation() == "Attack" and frame >= 3):
				if ( !fallPlayed ):
					sfxFall.play()
					fallPlayed = true

			if type == 1:
				if beat == 4 and cycle == 0:
					cycle = 1
					play("Jump")
					sfxJump.play()
					sfxJump2.play()

				if beat == 6:
					play("Attack")
					if ( !attackPlayed ):
						hitbox.set_deferred("disabled", false)
						attackPlayed = true
						sfxShockWave.play()
		else:
			if frame > 2:
				if !sfxKill.playing:
					sfxKill.play()
		if is_playing() and get_animation() == "Attack" and frame > 2:
			
			hitbox.set_deferred("disabled", true)

func _on_animation_finished():
	if get_animation() == "Attack":
		fallPlayed = false
		attackPlayed = false
		cycle = 0
		play("Idle")
	#if get_animation() == "Parried":
		#queue_free()

func _on_hitbox_body_entered(body):
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

#			var hitStopLength = 5.4 / 4.0 * seconds_per_beat
			var hitStopLength = 5.4 / 4.0 * seconds_per_beat
			
			body.hitStop(0.05, hitStopLength)
			body.parries += 1
			body.createParryText()
			hitbox.set_deferred("disabled", true)
			gotParried = true
			play("Parried")


func _on_enemy_hurtbox_area_entered(area):
	if area.name == "PunchHitbox" and !hasDied:
		hitEffect.modulate.a = 1
		if area.name != "BulletCol":
			player.mayHitSfx.play()
		hp -= 1
		player.velocity.x -= (25 * player.facing)
	elif (area.name == "AirRollHitbox" or area.name == "BulletCol") and !hasDied:
		hitbox.set_deferred("disabled", true)
		$StaticBody2D2/CollisionShape2D.set_deferred("disabled", true)
		player.mayHitSfx.play()
		#i know this code is shit leave me alone
		player.oldVelocityVertical = -286 * Conductor.singleFramephysicsSpeedMultiplier
		player.oldVelocity = (player.playerSprite.scale.x * ((6 + player.dashSpeed * 53) * Conductor.singleFramephysicsSpeedMultiplier))
		hp -= 3
