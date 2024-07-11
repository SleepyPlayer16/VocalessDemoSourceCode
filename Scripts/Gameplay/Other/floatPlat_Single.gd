extends StaticBody2D

@onready var spr = $AnimatedSprite2D
@onready var col = $CollisionShape2D

func _on_visible_on_screen_notifier_2d_screen_entered():
	spr.show()
	col.set_deferred("disabled", false)


func _on_visible_on_screen_notifier_2d_screen_exited():
	spr.hide()
	col.set_deferred("disabled", true)
