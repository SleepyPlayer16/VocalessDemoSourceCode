extends Sprite2D

var timer = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	timer+=delta
	if (timer <= 2 and timer >= 0):
		if (modulate.a < 1):
			modulate.a+=delta*2

	if (timer >= 2):
		modulate.a-=delta*2

	if (timer >= 4):
		get_tree().change_scene("res://path/to/scene.tscn")
