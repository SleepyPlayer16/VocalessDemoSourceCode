extends Node2D

var skipped = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$AudioStreamPlayer.stop()
		if (!skipped):
			$AnimationPlayer.play("skipped")
			skipped = true

func _on_animation_player_animation_finished(_anim_name):
	#Conductor.sceneName = "MainMenu"
	get_tree().change_scene_to_file("res://Scenes/Intro.tscn")
