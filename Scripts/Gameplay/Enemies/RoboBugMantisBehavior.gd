extends AnimatedSprite2D

var beatCounter = 0
var beginAttackPattern = false
var currentPhase = phases.IDLE
var gotParried = false
var playedParriedAnim = false
var dyieing = false
var dead = false

@onready var ray = $RayCast2D
@onready var player = get_parent().get_node_or_null("PlayerObject")
@onready var sfx = [$SenpaiNoticed, $AttackPrepare, $Vanish, $Attack, $Kill]
@onready var hitbox = $Area2D/CollisionShape2D

enum phases{
	IDLE,
	NOTICE,
	ATTACKINGPROCESS,
	PARRIED
}

func _ready():
	Conductor.beatSignal.connect(playIdle)
	
func _process(_delta):
	if currentPhase == phases.PARRIED:
		if !playedParriedAnim:
			playedParriedAnim = true
			if !dead:
				play("Parried")
		if frame > 6:
			if !sfx[4].playing and !dead:
				dead = true
				sfx[4].play()
	if beatCounter > 5:
		beatCounter = 0
		currentPhase = phases.IDLE

func playIdle():
	if !gotParried:
		rhythmLogic()
		
func rhythmLogic():
	if player != null:
		if player.position.x < position.x:
			scale.x = 1
		else:
			scale.x = -1
	if (currentPhase == phases.IDLE):
		play("Idle")
		rayPlayerDetection()
	if (currentPhase == phases.NOTICE):
		match(beatCounter):
			0:
				sfx[0].play()
				play("Notice")
				beatCounter += 1
			1:
				sfx[1].play()
				play("Attack_Prepare")
				currentPhase = phases.ATTACKINGPROCESS
				beatCounter += 1
			5:
				currentPhase = phases.IDLE
				beatCounter = 0

	if (currentPhase == phases.ATTACKINGPROCESS):
		match(beatCounter):
			2:
				beatCounter += 1
			3:
				$Area2D2/CollisionShape2D.set_deferred("disabled", true)
				sfx[2].play()
				play("Vanish")
				beatCounter += 1
			4:
				$Area2D2/CollisionShape2D.set_deferred("disabled", false)
				sfx[3].play()
				play("Attack")
				rayPlayerDetection()
				z_index = 100
				beatCounter += 1
				hitbox.set_deferred("disabled", false)
			5:
				z_index = 0
				currentPhase = phases.IDLE
				hitbox.set_deferred("disabled", true)
				play("Idle")
				beatCounter += 1


func rayPlayerDetection():
	if ray.is_colliding():
		var collidingWith = ray.get_collider()
		if (collidingWith.name == "PlayerObject"):
			if beatCounter == 0:
				currentPhase = phases.NOTICE
			if beatCounter == 4:
				if !$RayCast2D2.is_colliding():
					position.x = player.position.x + (38 * scale.x)
				else:
					position.x = player.position.x
		else:
			if beatCounter == 4:
				position.x = ray.get_collision_point().x

func _on_area_2d_body_entered(body):
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
			currentPhase = phases.PARRIED
			$Area2D2/CollisionShape2D.set_deferred("disabled", true)
			gotParried = true
		hitbox.set_deferred("disabled", true)

func _on_area_2d_2_body_entered(body):
	if body.name == "PlayerObject":
		body.die = true

func _on_animation_finished():
	if get_animation() == "Parried":
		pass
