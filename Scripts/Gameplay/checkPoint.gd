extends Node2D

var activated = false
var disabled = false

@onready var col = $Area2D/CollisionShape2D

@export var twinCheckpoint = false

func _on_area_2d_body_entered(body):
	if (body.name == "PlayerObject" and !disabled):
		$checkSprite.frame = 1
		if (!activated):
			body.checkPoint(position.x+16, position.y )
			activate()
			$CheckHit.play()

func activate():
	activated = true
	$CPUParticles2D.emitting = true
	for checkpoint in get_tree().get_nodes_in_group("checkpointGroup"):
		if checkpoint.get_index() < self.get_index():
			if (!checkpoint.twinCheckpoint):
				$checkSprite.frame = 1
				checkpoint.col.set_deferred("disabled", true)


func _on_visible_on_screen_notifier_2d_screen_entered():
	if (!activated):
		col.set_deferred("disabled", false)
	$checkSprite.visible = true
		


func _on_visible_on_screen_notifier_2d_screen_exited():
	if (!activated):
		col.set_deferred("disabled", true)
	$checkSprite.visible = false
		
