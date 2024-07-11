extends Node2D

@export var laserType = 0

var is_casting = false
var chargingSoundPlaying = false
var fireSoundPlaying = false

@onready var spr = $AnimatedSprite2D
@onready var ray = $RayCast2D
@onready var laserLine = $Line2D
@onready var laserLine2 = $Line2D2
@onready var sfxCharge = $Charge
@onready var sfxFire = $Fire


func _ready():
	set_physics_process(true)
	laserLine.points[1] = Vector2.ZERO
	laserLine2.points[1] = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	var cast_point = ray.target_position
	ray.force_raycast_update()
	if is_casting:
		if laserType != 0:
			$CollisionPointFX.play("defaultBlue")
		else:
			$CollisionPointFX.play("default")
		$CollisionPointFX.visible = true
	else:
		$CollisionPointFX.visible = false
	if ray.is_colliding() and is_casting:
		cast_point = to_local(ray.get_collision_point())
		var collidingWith = ray.get_collider()
		if (collidingWith.name == "PlayerObject"):
			if !collidingWith.die: 
				collidingWith.die = true

	if is_casting:
		$CollisionPointFX.position.x = cast_point.x - 15
		laserLine.points[1].x = cast_point.x - 15
		laserLine2.points[1].x = cast_point.x - 15
	else:
		laserLine.points[1] = Vector2.ZERO
		laserLine2.points[1] = Vector2.ZERO
	if laserType == 0:
		match(Conductor.beatCounter):
			1:
				spr.play("Idle")
			2:
				if !chargingSoundPlaying:
					chargingSoundPlaying = true
					sfxCharge.play()
				spr.play("Charging")
			3:
				if !fireSoundPlaying:
					chargingSoundPlaying = false
					fireSoundPlaying = true
					sfxFire.play()

				set_is_casting(true)
			4:
				fireSoundPlaying = false
				is_casting = false
			5:
				spr.play("Idle")
	else:
		laserLine.default_color = "#3ebfff"
		match(Conductor.beatCounter):
			5:
				spr.play("IdleBlue")
			6:
				if !chargingSoundPlaying:
					chargingSoundPlaying = true
					sfxCharge.play()
				spr.play("ChargingBlue")
			7:
				if !fireSoundPlaying:
					chargingSoundPlaying = false
					fireSoundPlaying = true
					sfxFire.play()
				set_is_casting(true)
			8:
				fireSoundPlaying = false
				is_casting = false
			1:
				spr.play("IdleBlue")

func set_is_casting(cast):
	is_casting = cast

func _on_animated_sprite_2d_animation_finished():
	if spr.get_animation() == "Charging" or spr.get_animation() == "ChargingBlue":
		if laserType == 0:
			spr.play("Idle")
		else:
			spr.play("IdleBlue")
