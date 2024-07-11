extends AnimatedSprite2D

@onready var col = $Area2D/CollisionShape2D

func _on_area_2d_body_entered(body):
	if (body.name == "PlayerObject"):
			body.die = true


func _on_visible_on_screen_notifier_2d_screen_entered():
	col.set_deferred("disabled", false)


func _on_visible_on_screen_notifier_2d_screen_exited():
	col.set_deferred("disabled", true)
