extends Node2D

var state = states.NORMAL
@onready var spr = $Sprite2D
@onready var prepareSFX = $Prepare
@onready var shootSFX = $Shoot
@onready var snowBall = preload("res://Objects/LevelObjects/World4/snowBall.tscn")

enum states {
	NORMAL,
	PREPARE,
	SHOOT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Conductor.beatSignal.connect(prepareToShoot)

func prepareToShoot():
	match(Conductor.beatCounter):
		1:
			prepareSFX.play()
			state = states.PREPARE
			spr.play("Charge")
		3:
			shootSFX.play()
			state = states.SHOOT
			spr.play("Fire")
			spawn_snowBall(1)
		4:
			state = states.NORMAL
			spr.play("Normal")
		5:
			prepareSFX.play()
			state = states.PREPARE
			spr.play("Charge")
		7:
			shootSFX.play()
			state = states.SHOOT
			spr.play("Fire")
			spawn_snowBall(1)
		8:
			state = states.NORMAL
			spr.play("Normal")

func _on_sprite_2d_animation_finished():
	var current_animation = spr.get_animation()
	if (current_animation == "Fire"):
		spr.play("Normal")
		
func spawn_snowBall(direction: int):
	var id = snowBall.instantiate()
	id.direction = scale.x
	id.position = $Marker2D.position
	call_deferred("add_child", id)
	
