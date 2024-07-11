extends AnimatedSprite2D

var posy = 99999999999
var posx = 0
var canBeReused = true

func _process(_delta):
	if frame >= 5:
		visible = false
		canBeReused = true
