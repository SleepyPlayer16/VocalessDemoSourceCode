extends CanvasLayer

var time_elapsed = 0
var inputBeat = false
var comboCounterInitialPos
var modulateTimer = 0.5
var activateModulate = true

func _ready():
	$stuff/TimerText.clip_contents = false
	$stuff/Combo.clip_contents = false
	if get_tree().current_scene.name == "TUTORIAL":
		$stuff/Combo.position.y -= 330
		$stuff/TrickNam.position.y += 30
		$stuff/Tricks.position.y += 30
	comboCounterInitialPos = $stuff/Combo/ComboNumber.position

func _process(delta):
	if (activateModulate):
		if (modulateTimer <= 0):
			if ($stuff.modulate.a < 1):
				$stuff.modulate.a = lerp($stuff.modulate.a, 1.0, (0.06 * 60) * delta)
		else:
			modulateTimer -= delta
	if !get_parent().inCountdown and !get_parent().talking:
		time_elapsed += delta
	get_parent().timeElapsed = time_elapsed
	$stuff/TimerText.text = _format_seconds(time_elapsed, false)
	if (get_parent().parries != CharaHandler.idealParries):
		$stuff/Tricks.text = str(get_parent().parries) + "/" + str(CharaHandler.idealParries)
	else:
		$stuff/Tricks.text = "[color=green]" + str(get_parent().parries) + "/" + str(CharaHandler.idealParries) + "[/color]"
	$stuff/Combo.text = "COMBO: "
	$stuff/Combo/ComboNumber.text = str(Conductor.combo)
	if $stuff/Combo/ComboNumber.scale.x > 1 or $stuff/Combo/ComboNumber.scale.y > 1:
		$stuff/Combo/ComboNumber.scale.x = lerp(float($stuff/Combo/ComboNumber.scale.x), 1.0, (0.25*60)*delta)
		$stuff/Combo/ComboNumber.scale.y = lerp(float($stuff/Combo/ComboNumber.scale.y), 1.0, (0.25*60)*delta)
		
	if (get_parent().inputBeat):
		shake(0.2, 1)
		get_parent().inputBeat = false
		$stuff/Combo/ComboNumber.scale.x = 2
		$stuff/Combo/ComboNumber.scale.y = 2
		
	if Conductor.combo < 7 and $stuff/Combo.visible:
		$stuff/Combo.hide()
		
#	print(time_elapsed)
	
func _format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func shake(duration, amplitude):
	#TODO: FIX POS NOT BEING (0,0)
	var start_pos = comboCounterInitialPos
	var timer = get_tree().create_timer(duration)
	while timer.time_left > 0:
		$stuff/Combo/ComboNumber.position = start_pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))
		await(get_tree().process_frame)
	$stuff/Combo/ComboNumber.position = start_pos
