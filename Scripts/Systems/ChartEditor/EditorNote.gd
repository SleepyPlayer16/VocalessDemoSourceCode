extends Node2D

@onready var area = $noteAr/CollisionShape2D

var mouseIn = false
var isMouseInside: bool = false
var timeStamp: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	get_tree().set_debug_collisions_hint(true) 

#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion:
#		var mouseEvent = event as InputEventMouseMotion
#		isMouseInside = area.collision_(mouseEvent.position)
#		if isMouseInside:
#			print("Mouse entered")
#		else:
#			print("Mouse exited")

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed() and event is InputEventMouseButton:
		var mouseEvent = event as InputEventMouseButton
		if mouseEvent.button_index == MOUSE_BUTTON_RIGHT:
			print("pressed!")
