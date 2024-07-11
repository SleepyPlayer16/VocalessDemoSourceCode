extends StaticBody2D

@export var side = 1
@onready var spr = $DebugWallVines
var current_world = ""
#no
#func _ready():
	#if get_tree().current_scene.name == "SOLAR_CITY" or get_tree().current_scene.name == "TUTORIAL":
		#current_world = "SolarCity"
	#elif get_tree().current_scene.name == "DRAGONIA_FOREST":
		#current_world = "DragoniaForest"
	#elif get_tree().current_scene.name == "FROSTFALL":
			#current_world = "Frostfall"
	#elif get_tree().current_scene.name == "JET_CITY":
			#current_world = "JetCity"
	#if side == -1:
		#spr.scale.x = 1
		#spr.frame = 1
	#spr.texture = load("res://Sprites/Tilesets/World_" + current_world + "/Vines.png")
