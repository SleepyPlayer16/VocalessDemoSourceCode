extends Node2D

@onready var colMap1 = $GroundTiles2
#
#func _process(delta):
	#pass
#
#
func _on_visible_on_screen_notifier_2d_screen_entered():
	show()


func _on_visible_on_screen_notifier_2d_screen_exited():
	hide()
