extends StaticBody2D

var destroyed = false
var prepareForDestruct = false
var hitStopActive = false
var hitStopTimer = 0
var hitStopDecreaseSpeed = 0

@onready var col = $CollisionShape2D
@onready var part1 = $part1
@onready var part2 = $part2
@onready var part3 = $part3
@onready var spr = $Sprite2D
@onready var breakSFX = $Break

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed:
		col.set_deferred("disabled", true)
	freezeManage(delta)

func freezeManage(delta):
	if (hitStopTimer > 0):
		hitStopTimer -= (hitStopDecreaseSpeed * 60) * delta
	else:
		hitStopTimer = 0
		hitStopDecreaseSpeed = 0
		hitStopActive = false
		if destroyed:
			if !prepareForDestruct:
				prepareForDestruct = true
				col.set_deferred("disabled", true)
				spr.visible = false
				breakSFX.play()
				part1.emitting = true
				part2.emitting = true
				part3.emitting = true

func hitStop(timeScale, duration):
	hitStopActive = true
	hitStopTimer = duration
	hitStopDecreaseSpeed = timeScale
