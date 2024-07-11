extends Sprite2D

var judgement_type = 0
var originalPositionInPool
var posx = null
var posy = null
var canBeReused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	originalPositionInPool = position

func _process(delta):
	if Conductor.sceneName != "":
		if (!canBeReused):
			scale.x+=(.03*delta)*60
			scale.y+=(.03*delta)*60
			if posx != null:
				if get_tree().current_scene.name != "menu":
					visible = true
			else:
				visible = false
			position.x = posx
			position.y = posy
			modulate.a8 -= (8*60) * delta

		if modulate.a8 <= 0:
			if (!canBeReused):
				posx = null
				judgement_type = 0
				posy = null
				position = originalPositionInPool
				canBeReused = true
