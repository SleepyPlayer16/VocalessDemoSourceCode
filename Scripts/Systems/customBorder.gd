extends Control

var mouseEntered = false
var minimizeTimer = 0
var currentStatus = states.WINDOWED
var minimized = true
var resizing = false
var following = false
var draggingStart = Vector2()
var sizeTimer = 0
var resizeNode
var lastWinSize
var windowSize

enum states{
	WINDOWED,
	MAXIMIZED
}

func _ready():
	if (OS.get_name() == "Web"):
		$Area2D/CollisionShape2D.disabled = true
		hide()

func _process(delta):
	if (OS.get_name() != "Web"):
		if (Input.is_action_just_released("mouseRelease")):
			following = false
		if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN and mouseEntered):
			mouseEntered = false

		if (lastWinSize != DisplayServer.screen_get_usable_rect() and $SprWindowBorder/Size.frame == 1):
			maximBULLSHIT()

		if (following and $SprWindowBorder/Size.frame == 2):
			if (DisplayServer.window_get_size() == Vector2i(480, 270)):
				DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_viewport().get_mouse_position()/2 - draggingStart/2))
			else:
				DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_viewport().get_mouse_position() - draggingStart)) 
		if (!following):
			if (DisplayServer.window_get_position().y < 0):
				DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, 0))

			if (DisplayServer.window_get_position().x > DisplayServer.screen_get_usable_rect().size.x-50):
				DisplayServer.window_set_position(Vector2i(DisplayServer.screen_get_usable_rect().size.x-(80*UserData_Handler.windoSize), DisplayServer.window_get_position().y))
			#########################
			if (DisplayServer.window_get_position().y > DisplayServer.screen_get_usable_rect().size.y-10):
				DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position().x, DisplayServer.screen_get_usable_rect().size.y-(20*UserData_Handler.windoSize)))

			if (DisplayServer.window_get_position().x < -460*UserData_Handler.windoSize):
				DisplayServer.window_set_position(Vector2i(-400*UserData_Handler.windoSize, DisplayServer.window_get_position().y))

		if (mouseEntered):
			$SprWindowBorder.position.y = lerp($SprWindowBorder.position.y, 0.0, (0.3*60)*delta)
			$RichTextLabel.position.y = lerp($RichTextLabel.position.y, 4.0, (0.3*60)*delta)
		else:
			following = false
			$SprWindowBorder.position.y = lerp($SprWindowBorder.position.y, -48.0, (0.3*60)*delta)
			$RichTextLabel.position.y = lerp($RichTextLabel.position.y, -32.0, (0.3*60)*delta)

		if (minimizeTimer > 0):
			minimizeTimer -= (1*60)*delta
		else:
			if (!minimized):
				minimized = true
				get_tree().root.mode = Window.MODE_MINIMIZED
		if (sizeTimer > 0):
			sizeTimer -= (1*60)*delta

func _on_area_2d_mouse_entered():
	if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN):
		mouseEntered = true

func _on_area_2d_mouse_exited():
	if (!following):
		mouseEntered = false


func _on_minimize_area_2d_input_event(_viewport, _event, _shape_idx):
	if (_event is InputEventMouseButton && _event.pressed):
		minimizeTimer = 1
		mouseEntered = false
		minimized = false
		$SprWindowBorder.position.y = -48.0

#func _notification(what):
	#if what == NOTIFICATION_WM_MOUSE_ENTER:
		#print("enter")
	#elif what == NOTIFICATION_WM_MOUSE_EXIT:
		#print("exit")


func _on_size_area_2d_input_event(_viewport, _event, _shape_idx):
	if (_event is InputEventMouseButton && _event.pressed):
		if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN):
			if ($SprWindowBorder/Size.frame == 2):
				maximBULLSHIT()
				UserData_Handler.maximized = true
				$SprWindowBorder/Size.frame = 1
			if ($SprWindowBorder/Size.frame == 1 and sizeTimer <= 0):
				sizeTimer = 1
				following = false
				mouseEntered = false
				$SprWindowBorder/Size.frame = 2
				UserData_Handler.maximized = false
				DisplayServer.window_set_size(Vector2i(480*UserData_Handler.windoSize,270*UserData_Handler.windoSize))
				DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - DisplayServer.window_get_size() / 2)

func maximBULLSHIT():
	if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN):
		sizeTimer = 1
		mouseEntered = false
		var realWindowSize =  DisplayServer.screen_get_usable_rect()
		var taskSize= DisplayServer.screen_get_size().y - DisplayServer.screen_get_usable_rect().size.y
		DisplayServer.window_set_size(Vector2i(realWindowSize.size.x,realWindowSize.size.y))
		DisplayServer.window_set_position(Vector2i(realWindowSize.size.x,DisplayServer.screen_get_size().y-taskSize) / 2 - DisplayServer.window_get_size() / 2)
		following = false
		lastWinSize = realWindowSize

func _on_exit_area_2d_input_event(_viewport, _event, _shape_idx):
	if (_event is InputEventMouseButton && _event.pressed):
		get_tree().quit()

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if (_event is InputEventMouseButton && _event.get_button_index() == 1):
		if mouseEntered:
			following = _event.is_pressed()
			draggingStart = get_viewport().get_mouse_position()

func _on_resize_top_gui_input(event):
	if (event is InputEventMouseButton and event.get_button_index() == 1):
		gui_input_handling(event, $Right)

func _on_bottom_gui_input(event):
	if (event is InputEventMouseButton and event.get_button_index() == 1):
		gui_input_handling(event, $Bottom)

func _on_corner_gui_input(event):
	if (event is InputEventMouseButton and event.get_button_index() == 1):
		gui_input_handling(event, $Corner)

func gui_input_handling(event: InputEventMouseButton, node: Control) -> void:
	if !resizing:
		resizeNode = node
	resizing = event.is_pressed()
