extends Line2D

var target
var point
@export var targetPath: NodePath
@export var trailLength = 0 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetPath)
	pass # Replace with function body.

func _process(_delta):
	global_position = Vector2(0,0)
	global_rotation = 0
	point = target.global_position
	add_point(point)
	while (get_point_count()*_delta)*60 > trailLength:
		remove_point(0)
	pass

func _exit_tree():
	queue_free()
