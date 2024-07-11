extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _draw():
	draw_line(Vector2.ZERO, get_global_mouse_position(), Color.WHITE, 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
