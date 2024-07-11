extends Node2D

var timer = 0
var timerStart = 2
var currentFrame = 0
var pixelScrollSpeed = 8
var skipped = false
var villainFrameActive = false
var bookFrameActive = false
var frameTime = [16.36, 20.72, 26.18, 29.45, 42.54, 46.90, 55.63, 60.0, 64.36, 68.72, 72.0, 73.09, 76.36, 78.54, 80.72, 82.90, 999.99]
var txtTime = [8.72, 17.45, 20.72, 29.45, 37.09, 43.63, 46.90, 53.45, 56.72, 60.0, 9999.99]
var started = false
var textSpeed = 0.04
var introText = "res://Dialogue/Intro/intro_en.json"
var currentText = 0
var fuckingWait = 0
var bookFUCKINGFinished = false
var playonce = false
var parsedText = []
var introTimer = 0.0

@onready var txt = $RichTextLabel
@onready var audiplayer = $AudioStreamPlayer

var tabcheat_callback = JavaScriptBridge.create_callback(_on_tab_cheat)
var focuscheat_callback = JavaScriptBridge.create_callback(_on_focus_cheat)


#func _notification(what):
	#if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		#audiplayer.stream_paused = false
	#elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		#get_tree().paused = true
		#if (get_tree().paused):
			#audiplayer.stream_paused = true
			#print("heyooo")
#

func _on_tab_cheat(_event):
	#get_tree().paused = true
	if (!audiplayer.stream_paused):
		audiplayer.stream_paused = true
	else:
		audiplayer.stream_paused = false
	
func _on_focus_cheat(_event):
	get_tree().paused = true

func _ready():
	if (OS.get_name() == "Web"):
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", tabcheat_callback) 
	parsedText = readJSON(introText)
	$Timer.wait_time = textSpeed
	$"Intro1-7".modulate.a = 0

func _process(delta):
	introTimer = Time.get_ticks_usec()
	#prepare to see the worst code in history
	if Input.is_action_just_pressed("SkipIntro"):
		#skip the FUCKING intro
		$AudioStreamPlayer.stop()
		skipped = true
	
	$ColorRect2.modulate.a -= (0.01*60)*delta
	timerStart -= delta
	if timerStart <= 0:
		if !started:
			$Timer.start()
			started = true
			$AudioStreamPlayer.play()
			$"Intro1-7".modulate.a = 0
			$"Intro1-7".visible = true
			playAnimation(1, "FadeInOut", 0, frameTime[0])

	if started:
		txt.text = parsedText[currentText]["Text"]
#
	#if Input.is_action_just_pressed("fastForward"):
		#if !started:
			#playAnimation(1, "FadeInOut", 0, frameTime[0])
			#$Timer.start()
			#started = true
			#$AudioStreamPlayer.play()
			#$"Intro1-7".visible = true
		#else:
			#currentFrame = 6
			#$AudioStreamPlayer.seek(53.45)
			#playAnimation(8, "FadeInOut", 0, frameTime[currentFrame])
#
	if $AudioStreamPlayer.get_playback_position() >= frameTime[currentFrame]:
		if $Villain.modulate.a <= 0 and villainFrameActive: 
			villainFrameActive = false
			currentFrame += 1
		if !(villainFrameActive or bookFrameActive) and !(frameTime[currentFrame] == 70.0):
			if currentFrame < 12:
				playAnimation(0.7, "FadeInOut_2", currentFrame, 0.5)
			else:
				playAnimation(60, "FadeInOut_2", currentFrame, 0.5)
		if ($Book.modulate.a <= 0):
			if (bookFrameActive and !bookFUCKINGFinished):
				bookFUCKINGFinished = true
				bookFrameActive = false
				currentFrame += 1
				playAnimation(0.29, "FadeInOut_2", currentFrame, 0.5)

		if villainFrameActive:
			$Villain.modulate.a -= (0.015 * 60) * delta
			$VillainBack.modulate.a -= (0.015 * 60) * delta
		if bookFrameActive:
			$Book.modulate.a -= (0.015 * 60) * delta
			$BookBack.modulate.a -= (0.015 * 60) * delta

	if $AudioStreamPlayer.get_playback_position() >= txtTime[currentText]:
		txt.visible_characters = 0
		currentText += 1
		$Timer.start()
		
	if villainFrameActive:
		pixelScrollSpeed -= (60 * delta)
		$VillainBack.rotation_degrees += (1 * 60) * delta
		if pixelScrollSpeed <= 0:
			pixelScrollSpeed = 6
			if $Villain.position.y < 152:
				$Villain.position.y += 3
				
	if bookFrameActive:
		pixelScrollSpeed -= (60 * delta)
		if pixelScrollSpeed <= 0:
			pixelScrollSpeed = 6
			$Book.position.x -= 0.5
	if currentFrame > 15 or skipped:
		if !skipped:
			$SprLayout.modulate.a -= (0.007 * 60) * delta
		else:
			$VillainBack.visible = false
			$Villain.visible = false
			$Book.visible = false
			$BookBack.visible = false
			$"Intro1-7".visible = false
			txt.visible = false
			$SprLayout.modulate.a -= (0.1 * 60) * delta

	if $SprLayout.modulate.a < 0.5:
		$SprNoVoiceLogo.position.x = lerpf($SprNoVoiceLogo.position.x, 173.0, (0.05 * 60) * delta )
		$SprNoVoiceLogo.position.y = lerpf($SprNoVoiceLogo.position.y, 47.0, (0.05 * 60) * delta )
	if $SprLayout.modulate.a <= -0.8:
		Conductor.sceneName = "MainMenu"
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		Conductor.gamePaused = false

func playAnimation(spd, animName, frme, _holdForHowLong):
	#i could probably code something better than this, but i don't feel like it
	if (frme < $"Intro1-7".hframes):
		$"Intro1-7".frame = frme
	elif frme == 8:
		$Villain.visible = true
		$VillainBack.visible = true
		$"Intro1-7".visible = false
		villainFrameActive = true
	elif frme == 9:
		if !bookFrameActive:
			bookFrameActive = true
			pixelScrollSpeed = 6
			$Book.visible = true
			$BookBack.visible = true

	elif frme == 10:
		$Last.visible = true
		$Last.play("10")
		#print("YOU")
	elif frme == 11:
		$Last.play("11Before")
	elif frme == 12:
		$Last.position.y = 160
		$Last.play("11")
	elif frme == 13:
		if !playonce:
			$Last.play("12")
			playonce = true
	elif frme == 14:
		$Last.position.y = 116
		$Last.play("13")
	elif frme == 15:
		$Last.visible = false
	elif frme == 16:
		$SprNoVoiceLogo.visible = true
	$AnimationPlayer.play(animName, -1, spd, false)

func readJSON(json_file_path) -> Array:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var finish = JSON.parse_string(content)
	return finish

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "FadeInOut_2":
		
		if !(villainFrameActive or bookFrameActive):
			if currentFrame < len(frameTime) - 1:
				#print("god FUCKING dammit")
				#print("AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH: ", currentFrame)
				if fuckingWait == 0:
					currentFrame += 1
		if fuckingWait == 0:
			playAnimation(1, "FadeInOut", currentFrame, frameTime[currentFrame])


func _on_timer_timeout():
	txt.visible_characters += 1
	$Timer.start()
