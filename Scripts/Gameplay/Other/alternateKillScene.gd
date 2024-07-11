extends Node2D

var timerA = 0.07
var timerB = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timerA > 0:
		timerA -= delta
	if timerA <= 0:
		timerA = 0.07
		shake(30)

	if timerB > 0:
		timerB -= delta

	if timerB <= 0:
		timerB = 0.1
		shake2(20)
func shake(amplitude: float):
	var start_pos = Vector2(424, 128)
	$RichTextLabel.position = start_pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))

func shake2(amplitude: float):
	var start_pos = Vector2(480, 272)
	$AnimatedSprite2D.position = start_pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))
