extends Node2D

var timer = 20
var hasplayed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused:
		if (!hasplayed):
			hasplayed = true
			$AudioStreamPlayer.play()
		$Sprite2D.scale.x = lerp($Sprite2D.scale.x, 2.0, (0.1*60)*delta)
		$Sprite2D.scale.y = lerp($Sprite2D.scale.x, 2.0, (0.1*60)*delta)
