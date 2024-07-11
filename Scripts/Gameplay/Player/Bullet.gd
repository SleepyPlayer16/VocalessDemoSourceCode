extends Node2D

@onready var sfx = $AudioStreamPlayer
@onready var sfx2 = $WallDestroy
@onready var particles = $CPUParticles2D
@onready var particles2 = $CPUParticles2D2
@onready var raycast = $RayCast2D

var timerCreated = false
var timer
var col = null
var anticipation = 0
var speed = 0
var speeed = 0.8
var max_speed = 200.0
var speedIncrement = 0.01
var distance
var dir = -1
var queueForDeletion = false
var breakInstantly = false
var timerDelete = 0.5
var collided = false

var initialPos

# Called when the node enters the scene tree for the first time.
func _ready():
	sfx.play()
	initialPos = position
	particles2.scale.x *= dir
	if dir == 1:
		raycast.target_position.x = 960
	else:
		raycast.target_position.x = -960
#	Conductor.beatSignalBPM.connect(teleportBullet)

func _process(delta):
	if queueForDeletion:
		#print("BRO")
		timerDelete -= delta
	if (timerDelete <= 0):
		queue_free()

	if (raycast.is_colliding()):
		col = raycast.get_collision_point()
		distance = position.distance_to(col)
		teleportBullet()
		collided = true

	else:
		await get_tree().create_timer((0.076*60)*delta).timeout
		if not collided:
#			print("FUCKkk")
			teleportBullet()
	if breakInstantly:
		if ($sprBullet.visible):
			$sprBullet.visible = false
			$sprBullet.hide()
			if (!particles.emitting):
				particles.emitting = true
				queueForDeletion = true

func teleportBullet():
	anticipation += 3
	if !breakInstantly:
		if anticipation >= 2:
			if (!queueForDeletion):
				particles.scale.x = dir
				if col:
					queueForDeletion = true
					position.x = col.x + (dir * 3)
					$sprBullet.visible = false
					if (!particles.emitting):
						particles.emitting = true
				else:
					queueForDeletion = true
					position.x += (960 * 5) * dir
					$sprBullet.visible = false
					if (!particles.emitting):
						particles.emitting = true
						
func _on_bullet_col_body_entered(_body):
	if breakInstantly:
		if ($sprBullet.visible):
			breakInstantly = true
			$sprBullet.hide()
			if (!particles.emitting):
				particles.emitting = true
				queueForDeletion = true


func _on_bullet_col_area_entered(area):
	if(area.name == "enemyHurtbox"):
		pass
