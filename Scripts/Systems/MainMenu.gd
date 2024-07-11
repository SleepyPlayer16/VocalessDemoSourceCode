extends Node

const OPTIONS_POSITIONS = [38, 102, 166, 230, 294, 358,38, 166, 230]
const OPTIONS_POSITIONSWEB = [38, 102, 166, 230, 294, 448]

var currentOption = 1
var numberOfOptions = 4

var currentOptionsMenuOptioin = 1
var numberOfOptionsMenuOptions = 8
var numberOfOptionsWebMenuOptions = 6

var canMove = false
var isInOptionsMenu = false
var isInControlsMenu = false

var volume
var sfx
var fullscreen
var vsync
var cameraSmoothing
var windowSize
var fps

@onready var menuOptions = $Main/SprMainMenuOptions
@onready var scrollingBack = $ParallaxBackground/ParallaxLayer
@onready var animPlayer = $Main/AnimationPlayer
@onready var optionsSelector = $OptionsMenu/Selector
@onready var fullscreenOption = $OptionsMenu/Normal_options/SprFullscreenOption
@onready var camSmoothOption = $OptionsMenu/Normal_options/SprCameraSmoothingOption
@onready var fpsTimer = $fpsTimer
@onready var volumeTimer = $volumeTimer
@onready var vsyncOption = $OptionsMenu/Normal_options/SprVsyncOption
#why did i do this???? i dont feel like fixing it tho, it already works
@onready var optionsNode = $OptionsMenu
@onready var optionsControlsMenu = optionsNode.get_node("InputRemapping_Menu")
@onready var optionsGamepadMenu = optionsNode.get_node("InputRemapping_Menu/InputRemapping_Pad")

@onready var normalOptions = $OptionsMenu/Normal_options
@onready var webOptions = $OptionsMenu/WebOptions
@onready var OpMenuBackground = $OptionsMenu/OptionsMenuBack
@onready var optionsWeb = preload("res://Sprites/Menu/spr_mainMenuOptionsWeb.png")
@onready var menuSong = preload("res://Music/mus_mainmenuNew.ogg")

func _ready():
	if (OS.get_name() == "Web"):
		normalOptions.visible = false
		numberOfOptions = 3
		$Main/SprMainMenuOptions.texture = optionsWeb
		fullscreenOption = $OptionsMenu/WebOptions/SprFullscreenOption
		camSmoothOption = $OptionsMenu/WebOptions/SprCameraSmoothingOption
	else:
		webOptions.visible = false
	Conductor.inputChange.connect(controlChange)
	controlChange()
	CharaHandler.goToTutorial = false
	CharaHandler.difficulty = CharaHandler.difficulties.NORMAL
	volume = UserData_Handler.default_data["musicVolume"]
	sfx = UserData_Handler.default_data["sfxVolume"]
	fullscreen = UserData_Handler.default_data["fullscreen"]
	vsync = UserData_Handler.default_data["vsync"]
	cameraSmoothing = UserData_Handler.default_data["cameraSmoothing"]
	windowSize = UserData_Handler.default_data["windowSize"]
	fps = UserData_Handler.default_data["fps"]
	
	if (OS.get_name() == "Web"):
		$OptionsMenu/WebOptions/HSlider.value = volume
		$OptionsMenu/WebOptions/HSlider2.value = sfx
		$OptionsMenu/WebOptions/Fps.text = str(fps)
	else:
		$OptionsMenu/Normal_options/HSlider.value = volume
		$OptionsMenu/Normal_options/HSlider2.value = sfx
		$OptionsMenu/Normal_options/Fps.text = str(fps)
		$OptionsMenu/Normal_options/SprWindowSize.frame = windowSize-1
	#if for some FUCKING reason user has the automatic window toolbar hide thing on then CHECK FOR IT CUZ GODOT THINKS
	#THE GAME IS ON FULLSCREEN MODE FOR SOME GO DAMN REASON
	if (DisplayServer.screen_get_size() == DisplayServer.window_get_size()):
		DisplayServer.window_set_size(Vector2i(DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y-1))
	if (fullscreen or (DisplayServer.screen_get_size() == DisplayServer.window_get_size())):
		fullscreenOption.frame = 0
	else:
		fullscreenOption.frame = 1

	if (vsync):
		vsyncOption.frame = 0
	else:
		vsyncOption.frame = 1

	if (cameraSmoothing):
		camSmoothOption.frame = 0
	else:
		camSmoothOption.frame = 1

	animPlayer.play("EnterScene")
	Conductor.songToLoad(125,-3,menuSong)

func _process(delta):
	scrollingBack.motion_offset.x -= 35*delta
	if (isInOptionsMenu and !isInControlsMenu):
		if Input.is_action_pressed("ui_left"):
			if (fpsTimer.is_stopped()):
				if (OS.get_name() != "Web"):
					if (currentOptionsMenuOptioin == 8):
						if (fps > 60):
							fpsTimer.start()
							fps -= 5
							UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					$OptionsMenu/Normal_options/Fps.text = str(fps)
				else:
					if (currentOptionsMenuOptioin == 6):
						if (fps > 60):
							fpsTimer.start()
							fps -= 5
							UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					$OptionsMenu/WebOptions/Fps.text = str(fps)
					print(fps)
			if (currentOptionsMenuOptioin == 1):
				if (volumeTimer.is_stopped()):
					volumeTimer.start()
					$OptionsMenu/Normal_options/HSlider.value -= 1 
			elif (currentOptionsMenuOptioin == 2):
				if (volumeTimer.is_stopped()):
					volumeTimer.start()
					$OptionsMenu/Normal_options/HSlider2.value -= 1
		elif Input.is_action_pressed("ui_right"):
			if (fpsTimer.is_stopped()):
				if (OS.get_name() != "Web"):
					if (currentOptionsMenuOptioin == 8):
						if (fps < 240):
							fpsTimer.start()
							fps += 5
							UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					$OptionsMenu/Normal_options/Fps.text = str(fps)
				else:
					if (currentOptionsMenuOptioin == 6):
						if (fps < 240):
							fpsTimer.start()
							fps += 5
							UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					$OptionsMenu/WebOptions/Fps.text = str(fps)
			if (currentOptionsMenuOptioin == 1):
				if (volumeTimer.is_stopped()):
					volumeTimer.start()
					$OptionsMenu/Normal_options/HSlider.value += 1 
			elif (currentOptionsMenuOptioin == 2):
				if (volumeTimer.is_stopped()):
					volumeTimer.start()
					$OptionsMenu/Normal_options/HSlider2.value += 1

	if (currentOptionsMenuOptioin > 6):
		OpMenuBackground.position.y = lerp(OpMenuBackground.position.y, -512.0, (0.1*60)*delta)
		normalOptions.position.y = lerp(normalOptions.position.y, -464.0, (0.4*60)*delta)
	else:
		OpMenuBackground.position.y = lerp(OpMenuBackground.position.y, 0.0, (0.1*60)*delta)
		normalOptions.position.y = lerp(normalOptions.position.y, 0.0, (0.4*60)*delta)

func _input(event):
	if (!isInOptionsMenu):
		mainMenu(event)
	else:
		if (OS.get_name() != "Web"):
			optionsMenu(event)
		else:
			optionsMenuWeb(event)

func optionsMenu(event):
	if (!isInControlsMenu):
		if (canMove):
			if event.is_action_pressed("ui_down"):
				Conductor.menuMoveSfx.play()
				currentOptionsMenuOptioin = (currentOptionsMenuOptioin % numberOfOptionsMenuOptions) + 1
				optionsSelector.position.y = OPTIONS_POSITIONS[currentOptionsMenuOptioin-1]
			if event.is_action_pressed("ui_up"):
				Conductor.menuMoveSfx.play()
				currentOptionsMenuOptioin = (currentOptionsMenuOptioin - 2 + numberOfOptionsMenuOptions) % numberOfOptionsMenuOptions + 1
				optionsSelector.position.y = OPTIONS_POSITIONS[currentOptionsMenuOptioin-1]
			if event.is_action_pressed("menuGoBack"):
				Conductor.menuGoBack.play()
				isInOptionsMenu = false
				Engine.max_fps = fps
				print(Engine.max_fps)
				canMove = true
				optionsNode.get_node("AnimationPlayerTwo").play("MenuOut")
			if event.is_action_pressed("menuAccept"):
				match(currentOptionsMenuOptioin):
					3:
						Conductor.menuSelectSfx.play()
						optionsControlsMenu.active = true
						optionsNode.get_node("Normal_options").hide()
						optionsControlsMenu.menuChange()
						optionsControlsMenu.show()
						isInControlsMenu = true
						optionsControlsMenu.currentIndex = 1
						optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[0]
					4:
						Conductor.menuSelectSfx.play()
						if DisplayServer.window_get_mode() == 0:
							fullscreenOption.frame = 0
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
							fullscreen = true
						else:
							fullscreenOption.frame = 1
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
							if (!UserData_Handler.maximized):
								DisplayServer.window_set_size(Vector2i(480*windowSize,270*windowSize))
								DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - DisplayServer.window_get_size() / 2)
							fullscreen= false
							UserData_Handler.save_settings(volume,sfx,fullscreen, vsync, cameraSmoothing, windowSize, fps)
					5:
						Conductor.menuSelectSfx.play()
						if DisplayServer.window_get_vsync_mode() == 1:
							vsyncOption.frame = 1
#							print("????")
							DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
							vsync = false
						else:
							vsyncOption.frame = 0
#							print("the fuck?")
							DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
							vsync = true
						UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					6:
						Conductor.menuSelectSfx.play()
						if (cameraSmoothing):
							cameraSmoothing = false
							camSmoothOption.frame = 1
						else:
							cameraSmoothing = true
							camSmoothOption.frame = 0
						UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
					7:
						Conductor.menuSelectSfx.play()
						windowSize += 1
						if (windowSize > 3):
							windowSize = 1
						UserData_Handler.windoSize = windowSize
						$OptionsMenu/Normal_options/SprWindowSize.frame = windowSize-1
						if (!UserData_Handler.maximized):
							DisplayServer.window_set_size(Vector2i(480*windowSize,270*windowSize))
							DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - DisplayServer.window_get_size() / 2)
						UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)

	else:
		if event.is_action_pressed("menuAccept"):
			optionsControlsMenu.changingKey = true
		if !(optionsControlsMenu.changingKey):
			if event.is_action_pressed("menuGoBack"):
				Conductor.menuGoBack.play()
				isInControlsMenu = false
				optionsSelector.position.y = OPTIONS_POSITIONS[2]
				optionsControlsMenu.hide()
				if (OS.get_name() != "Web"):
					optionsNode.get_node("Normal_options").show()
				else:
					optionsNode.get_node("WebOptions").show()
		
			if event.is_action_pressed("ui_down"):
				Conductor.menuMoveSfx.play()
				optionsControlsMenu.currentIndex = (optionsControlsMenu.currentIndex % optionsControlsMenu.options) + 1
				optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[optionsControlsMenu.currentIndex-1]
			if event.is_action_pressed("ui_up"):
				Conductor.menuMoveSfx.play()
				optionsControlsMenu.currentIndex = (optionsControlsMenu.currentIndex - 2 + optionsControlsMenu.options) % optionsControlsMenu.options + 1
				optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[optionsControlsMenu.currentIndex-1]

func optionsMenuWeb(event):
	if (!isInControlsMenu):
		if (canMove):
			if event.is_action_pressed("ui_down"):
				Conductor.menuMoveSfx.play()
				currentOptionsMenuOptioin = (currentOptionsMenuOptioin % numberOfOptionsWebMenuOptions) + 1
				optionsSelector.position.y = OPTIONS_POSITIONSWEB[currentOptionsMenuOptioin-1]
			if event.is_action_pressed("ui_up"):
				Conductor.menuMoveSfx.play()
				currentOptionsMenuOptioin = (currentOptionsMenuOptioin - 2 + numberOfOptionsWebMenuOptions) % numberOfOptionsWebMenuOptions + 1
				optionsSelector.position.y = OPTIONS_POSITIONSWEB[currentOptionsMenuOptioin-1]
			if event.is_action_pressed("menuGoBack"):
				Conductor.menuGoBack.play()
				isInOptionsMenu = false
				Engine.max_fps = fps
				canMove = true
				optionsNode.get_node("AnimationPlayerTwo").play("MenuOut")
			if event.is_action_pressed("menuAccept"):
				match(currentOptionsMenuOptioin):
					3:
						Conductor.menuSelectSfx.play()
						optionsControlsMenu.active = true
						optionsNode.get_node("WebOptions").hide()
						optionsControlsMenu.menuChange()
						optionsControlsMenu.show()
						isInControlsMenu = true
						optionsControlsMenu.currentIndex = 1
						optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[0]
					4:
						Conductor.menuSelectSfx.play()
						if DisplayServer.window_get_mode() == 0:
							fullscreenOption.frame = 0
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
							fullscreen = true
						else:
							fullscreenOption.frame = 1
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
							if (!UserData_Handler.maximized):
								DisplayServer.window_set_size(Vector2i(480*windowSize,270*windowSize))
								DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - DisplayServer.window_get_size() / 2)
							fullscreen= false
							UserData_Handler.save_settings(volume,sfx,fullscreen, vsync, cameraSmoothing, windowSize, fps)
					5:
						Conductor.menuSelectSfx.play()
						if (cameraSmoothing):
							cameraSmoothing = false
							camSmoothOption.frame = 1
						else:
							cameraSmoothing = true
							camSmoothOption.frame = 0
						UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)

	else:
		if event.is_action_pressed("menuAccept"):
			optionsControlsMenu.changingKey = true
		if !(optionsControlsMenu.changingKey):
			if event.is_action_pressed("menuGoBack"):
				Conductor.menuGoBack.play()
				isInControlsMenu = false
				optionsSelector.position.y = OPTIONS_POSITIONSWEB[2]
				optionsControlsMenu.hide()
				if (OS.get_name() == "Web"):
					optionsNode.get_node("WebOptions").show()
				else:
					optionsNode.get_node("Normal_options").show()
		
			if event.is_action_pressed("ui_down"):
				Conductor.menuMoveSfx.play()
				optionsControlsMenu.currentIndex = (optionsControlsMenu.currentIndex % optionsControlsMenu.options) + 1
				optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[optionsControlsMenu.currentIndex-1]
			if event.is_action_pressed("ui_up"):
				Conductor.menuMoveSfx.play()
				optionsControlsMenu.currentIndex = (optionsControlsMenu.currentIndex - 2 + optionsControlsMenu.options) % optionsControlsMenu.options + 1
				optionsSelector.position.y = optionsControlsMenu.OPTIONS_POSITIONS[optionsControlsMenu.currentIndex-1]

func controlChange():
	if Conductor.playingWith == "keyboard":
		$Main/SprMenuSelectBtnHelper.frame = 0
	else:
		$Main/SprMenuSelectBtnHelper.frame = 1

func mainMenu(event):
	if (canMove):
		if event.is_action_pressed("ui_down"):
			Conductor.menuMoveSfx.play()
			currentOption = (currentOption % numberOfOptions) + 1
			menuOptions.frame = currentOption - 1
		if event.is_action_pressed("ui_up"):
			Conductor.menuMoveSfx.play()
			currentOption = (currentOption - 2 + numberOfOptions) % numberOfOptions + 1
			menuOptions.frame = currentOption - 1
		if event.is_action("menuAccept"):
			Conductor.menuSelectSfx.play()
			if (currentOption != 2):
				animPlayer.play("ExitScene")
			else:
				if (!isInOptionsMenu):
					isInOptionsMenu = true
					optionsNode.get_node("AnimationPlayerTwo").play("MenuIn")
			canMove = false

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "EnterScene"):
		canMove = true
	if (anim_name == "ExitScene"):
		match(currentOption):
			1:
				get_tree().change_scene_to_file("res://Scenes/Menus/CharacterSelect.tscn")
			3:
				CharaHandler.goToTutorial = true
				CharaHandler.difficulty = CharaHandler.difficulties.NORMAL
				get_tree().change_scene_to_file("res://Scenes/Menus/CharacterSelect.tscn")
			4:
				if (OS.get_name() == "Web"):
					pass
				else:
					get_tree().quit()

func _on_animation_player_two_animation_finished(anim_name):
	if (anim_name == "MenuIn"):
		canMove = true

func _on_h_slider_value_changed(value):
	volume = $OptionsMenu/Normal_options/HSlider.value
	$OptionsMenu/WebOptions/HSlider.value = $OptionsMenu/Normal_options/HSlider.value
	AudioServer.set_bus_volume_db(1, volume)
	UserData_Handler.save_settings(volume,sfx,fullscreen, vsync, cameraSmoothing, windowSize, fps)


func _on_h_slider_2_value_changed(value):
	sfx = $OptionsMenu/Normal_options/HSlider2.value
	$OptionsMenu/WebOptions/HSlider2.value = $OptionsMenu/Normal_options/HSlider2.value
	AudioServer.set_bus_volume_db(2, sfx)
	UserData_Handler.save_settings(volume, sfx, fullscreen, vsync, cameraSmoothing, windowSize, fps)
