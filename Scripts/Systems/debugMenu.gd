extends Node2D

var currentWorld = "TUTORIAL"
var level = 1
var loading = false

@onready var menuBtn1 = $Control/HBoxContainer/SolarCity
@onready var menuBtn2 = $Control/HBoxContainer/DragoniaForest
@onready var menuBtn3 = $Control/HBoxContainer/Frostfall
@onready var menuBtn4 = $Control/HBoxContainer/JetCity
@onready var menuBtn5 = $Control/HBoxContainer/Tutorial
@onready var charaSelectBtn = $Control/HBoxContainer2/CharaBtn
@onready var diffSelectBtn = $Control/HBoxContainer2/DiffBtn
@onready var worldLevelSelected = $Control/World
@onready var characterSelected = $Control/Character
@onready var difficultySelected = $Control/Difficulty

@onready var loadingScreen = preload("res://Scenes/Menus/LoadingScreen.tscn")


func _ready():
	Conductor.sceneName = "WorldSelect"
	if !Conductor.playing:
		Conductor.songToLoad(135,3,load("res://Music/DancingInTheWind.ogg"))
		Conductor.emit_signal("destroyNotes")
		Conductor.songReady = true
	Conductor.beatSignal.connect(zoomEffect)
	menuBtn1.get_popup().id_pressed.connect(_on_item_menu_pressed)
	menuBtn2.get_popup().id_pressed.connect(_on_item_menu_pressed2)
	menuBtn3.get_popup().id_pressed.connect(_on_item_menu_pressed3)
	menuBtn4.get_popup().id_pressed.connect(_on_item_menu_pressed4)
	menuBtn5.get_popup().id_pressed.connect(_on_item_menu_pressed5)
	
	charaSelectBtn.get_popup().id_pressed.connect(_on_character_menu_pressed)
	diffSelectBtn.get_popup().id_pressed.connect(_on_difficulty_menu_pressed)
	CharaHandler.difficulty = CharaHandler.difficulties.NORMAL
	CharaHandler.character = "Karu"
	worldLevelSelected.text = currentWorld + " " + str(level)
	characterSelected.text = CharaHandler.character
	difficultySelected.text = "NORMAL"
	
func _process(delta):
	if $Control.scale.x != 1.0:
		var blend = pow(0.5, delta * 8)
		$Control.scale.x = lerpf(1.0, $Control.scale.x, blend)
		$Control.scale.y = $Control.scale.x

func zoomEffect():
	$Control.scale.x = 1.02
	$Control.scale.y = 1.02

func _on_character_menu_pressed(id: int):
	CharaHandler.character = charaSelectBtn.get_item_text(id)
	characterSelected.text = CharaHandler.character
	
func _on_difficulty_menu_pressed(id: int):
	if id == 0:
		CharaHandler.difficulty = CharaHandler.difficulties.NORMAL
		difficultySelected.text = "NORMAL"
	elif id == 1:
		CharaHandler.difficulty = CharaHandler.difficulties.HARD
		difficultySelected.text = "HARD"

func _on_item_menu_pressed(id: int):
	selectFunc("SOLAR_CITY", id + 1)

func _on_item_menu_pressed2(id: int):
	selectFunc("DRAGONIA_FOREST", id + 1)

func _on_item_menu_pressed3(id: int):
	selectFunc("FROSTFALL", id + 1)

func _on_item_menu_pressed4(id: int):
	selectFunc("JET_CITY", id + 1)

func _on_item_menu_pressed5(id: int):
	selectFunc("TUTORIAL", id + 1)

func selectFunc(worldName, lvlId):
	if !loading:
		currentWorld = worldName
		level = lvlId
		worldLevelSelected.text = currentWorld + " " + str(level)
		print("res://Scripts/WorldControllers/" + currentWorld + "_manager.tres")

func instantiateLevelSelect_load():
	loading = true
	var instance = loadingScreen.instantiate()
	if (currentWorld != "TUTORIAL"):
		instance.scene = "res://Stages/" + currentWorld + "/" + currentWorld + "_" + str(level) + ".tscn"
	else:
		instance.scene = "res://Stages/World_Tutorial/" + currentWorld + ".tscn"
	instance.worldManager = "res://Scripts/WorldControllers/" + currentWorld + "_manager.tres"
	instance.level = str(level)
	
	call_deferred("add_child", instance)


func _on_ready_pressed():
	if !loading:
		instantiateLevelSelect_load()


func _on_effects_option_item_selected(index):
	if (index == 0):
		CharaHandler.effectsEnabled = true
	else:
		CharaHandler.effectsEnabled = false


func _on_beat_option_item_selected(index):
	if (index == 0):
		CharaHandler.beatHitsEnabled = true
	else:
		CharaHandler.beatHitsEnabled = false


func _on_rhythm_option_item_selected(index):
	if (index == 0):
		CharaHandler.rhythmSystemEnable = true
	else:
		CharaHandler.rhythmSystemEnable = false

func _on_debug_controls_item_selected(index):
	if (index == 0):
		CharaHandler.debugControlsEnabled = true
	else:
		CharaHandler.debugControlsEnabled = false

