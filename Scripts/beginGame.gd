extends Node2D

var mouseHovering = false
var normalScaleValue = 1.0
var maxScaleValue = 1.5
var scaleChangeSpeed = 0.08
var pressed = false
var timer = 1
@onready var jumpDust = load("res://Objects/FX/JumpDust.tscn")
@onready var judgement = load("res://Scenes/FX/judgement.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!pressed):
		if (mouseHovering):
			$SprPlayBtn.scale.x = lerp($SprPlayBtn.scale.x, maxScaleValue, (scaleChangeSpeed * 60) * delta)
			$SprPlayBtnAura.scale.x = lerp($SprPlayBtnAura.scale.x, maxScaleValue * 0.8 , (scaleChangeSpeed/2 * 60) * delta)
		else:
			$SprPlayBtn.scale.x = lerp($SprPlayBtn.scale.x, normalScaleValue, (scaleChangeSpeed * 60) * delta)
			$SprPlayBtnAura.scale.x = lerp($SprPlayBtnAura.scale.x, normalScaleValue, (scaleChangeSpeed/2 * 60) * delta)
	else:
		$SprPlayBtn.scale.x += (scaleChangeSpeed * 0.7) * 60 * delta
		$SprPlayBtnAura.scale.x += (scaleChangeSpeed * 0.2) * 60 * delta
		$SprPlayBtn.modulate.a -= (0.05 * 60) * delta
		$SprPlayBtnAura.modulate.a -= (0.05 * 60) * delta
		timer -= (delta)
		if timer <= 0:
			get_tree().change_scene_to_file("res://Scenes/game_setup.tscn")

	$SprPlayBtn.scale.y = $SprPlayBtn.scale.x
	$SprPlayBtnAura.scale.y = $SprPlayBtnAura.scale.x
	
	if (Input.is_action_just_pressed("mouseClick") and mouseHovering):
		pressed = true
		$SprDisclaimer.hide()
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("menuGoBack")):
		pressed = true
		$SprDisclaimer.hide()

func _on_area_2d_mouse_entered():
	mouseHovering = true


func _on_area_2d_mouse_exited():
	mouseHovering = false

