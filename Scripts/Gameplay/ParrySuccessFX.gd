extends AnimatedSprite2D

var posx = null
var posy = null
var fx = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	play(fx)

func _process(_delta):
	position.x = posx
	position.y = posy

func _on_animation_finished():
	queue_free()
