extends Node2D

@onready var points = [
	$ColorRect,
	$ColorRect2,
	$ColorRect3,
	$ColorRect4,
	$ColorRect5,
	$ColorRect6,
	$ColorRect7,
	$ColorRect8
]

var gravityForce = 1.1

#
#func _process(delta):
	#for i in range(0, 8):
		#points[i].position.y = i * gravityForce

