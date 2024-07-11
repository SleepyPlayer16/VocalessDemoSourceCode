extends CanvasLayer

var paused = false
var selectedOption = 0
var numOptions = 3
var goToMenu = false
var reset = false
var reloading = false
@onready var menuSong = preload("res://Music/mus_mainmenuNew.ogg")
@onready var loadingScreen = preload("res://Scenes/Menus/LoadingScreen.tscn")

func _ready():
	pass
func _process(_delta):
	if (paused):
		Engine.time_scale = 1
		$PauseMenu.frame = selectedOption
	#if paused and !reset:
		#if (Input.is_action_just_pressed("Pdown_ctr")):
			#selectedOption = (selectedOption + 1) % numOptions
		#if (Input.is_action_just_pressed("Pup_ctr")):
			#selectedOption = (selectedOption - 1 + numOptions) % numOptions

func _input(event):
	if paused and !reset:
		if ((event is InputEventKey)):
			if (event.pressed):
				if (event.is_action_pressed("pauseAccept")):
					if selectedOption == (0):
						$AnimationPlayer.play("Unpause")
					elif selectedOption == 1:
						if (!reset):
							Conductor.stop()
							reset = true
							$AnimationPlayer.play("Unpause")
					else:
						$AnimationPlayer.play("Unpause")
						goToMenu = true
					selectedOption = 0
				if (event.is_action_pressed("ui_down")):
					selectedOption = (selectedOption + 1) % numOptions
				if (event.is_action_pressed("ui_up")):
					selectedOption = (selectedOption - 1 + numOptions) % numOptions

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Unpause"):
		if !(reset or goToMenu):
			get_tree().paused = false
			Conductor.gamePaused = false
			paused = false
		elif reset:
			Conductor.songReset()
			Conductor.stop()
			StageReLoad()
		elif goToMenu:
			get_tree().paused = false
			Conductor.stop()
			Conductor.songReset()
			Conductor.songToLoad(125,-1,menuSong)
			Conductor.emit_signal("destroyNotes")
			Conductor.sceneName = "MainMenu"
			CutsceneHandler.npcCurrentlySpeaking = ""
			Conductor.gamePaused = false
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func StageReLoad():
#	print("loading level now...")
	var instance = loadingScreen.instantiate()
	Conductor.stopSoundEffects = false
	CutsceneHandler.npcCurrentlySpeaking = ""
	instance.scene = str(get_tree().get_current_scene().scene_file_path)
	instance.worldManager = "res://Scripts/WorldControllers/" + get_tree().get_current_scene().get_name() +"_manager.tres"
	if (CharaHandler.character == "May" and get_tree().current_scene.name == "TUTORIAL"):
		instance.level = "2"
	else:
		instance.level = CharaHandler.level
	Conductor.emit_signal("destroyNotes")
	call_deferred("add_child", instance)
