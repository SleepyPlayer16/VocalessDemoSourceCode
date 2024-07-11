extends AnimatedSprite2D

@onready var parent = get_tree().current_scene.get_node("PlayerObject")
var hasMatBeenSet = false
var canBeReused = true
var colors = []
var spriteFrames = null
var color = ""

func _ready():
	initialization()

func _process(delta):
	if (!canBeReused):
		if !(hasMatBeenSet and parent.playerSprite == null):
			hasMatBeenSet = false

			var parentMaterial = parent.playerSprite.get_material().get("shader_parameter/palette")
			get_material().set("shader_parameter/palette", parentMaterial)
		if (modulate.a > 0):
			modulate.a -= (0.025*60)*delta
		else:
			if (!canBeReused):
				hasMatBeenSet = false
				colors = []
				color = ""
				canBeReused = true
				visible = false
				

func initialization():
	if (parent.playerSprite != null):
		if (spriteFrames == null):
			spriteFrames = parent.playerSprite.sprite_frames
			sprite_frames = parent.playerSprite.sprite_frames
		animation = parent.playerSprite.animation
		frame = parent.playerSprite.frame
		if color == "blue":
			modulate = get_random_phantom_color()
		else:
			modulate = get_random_color()
		visible = true

func get_random_color():
	match (CharaHandler.character):
		"Karu":
			colors = [
				Color(1, 1, 0.5),      # Light yellow
				Color(1, 0.8, 0),      # Orange-yellow
				Color(1, 0.9, 0.6),    # Lighter shade of orange-yellow
				Color(1, 0.7, 0.3)     # Darker shade of orange-yellow
			]
		"Froo":
			colors = [
				Color(0.5, 1, 0.5),      # Light green
				Color(0.7, 1, 0.6),      # Lighter shade of green
			]
		"Liz":
			colors = [
				Color(1, 0.5, 0.5),      # Light pink
				Color(1, 0.7, 0.7),      # Lighter shade of pink
			]
		"May":
			colors = [
				Color(0.5, 0.5, 1),      # Light blue
				Color(0.7, 0.7, 1),      # Lighter shade of blue
			]
		"Nix":
			colors = [
				Color(0.5, 0.5, 1),      # Light blue
				Color(0.7, 0.7, 1),      # Lighter shade of blue
			]
		"Lane":
			colors = [
				Color(0.5, 0.5, 1),      # Light blue
				Color(0.7, 0.7, 1),      # Lighter shade of blue
			]
		"Applesauce":
			colors = [
				Color(1, 0.5, 0.5),      # Light red
				Color(1, 0.7, 0.7),      # Lighter shade of red
			]
	return colors[randi() % colors.size()]

func get_random_phantom_color():
	var colorss = [
		Color(0.5, 0.8, 1),      # Light blue
	]
	return colorss[randi() % colorss.size()]
