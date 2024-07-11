extends Control

const CHARACTER_LIST_PATH = "res://Characters/CharacterList.tres"
var characters = []

var selectedIndex = 0
var canMove = false
var hasSelected = false
var hasGoneBack = false
var goToTutorial
var selectedAlt = 0
var waitAbit = 0.5
var numberOfCharacters = 3
var spd = 0.0

@onready var backCharaColor = $SprWorldBackColorThing
@onready var animPlayer2 =$AnimationPlayer2
@onready var namespr1 = $ParallaxBackground/ParallaxLayer2/Names
@onready var namespr2 = $ParallaxBackground/ParallaxLayer2/Names2
@onready var namespr3 = $ParallaxBackground/ParallaxLayer2/Names3
@onready var controlTex = preload("res://Sprites/Menu/spr_altPickerController.png")
@onready var keybodoTex = preload("res://Sprites/Menu/spr_altPicker.png")

@onready var textureRects = [
	$HBoxContainer/TextureRectLeft, 
	$HBoxContainer/TextureRect, 
	$HBoxContainer/TextureRectRight, 
	$HBoxContainer/TextureRectLeft2,
]

@onready var characterTexRectLeft = $HBoxContainer/TextureRectLeft
@onready var characterTexRect = $HBoxContainer/TextureRect
@onready var characterTexRectRight = $HBoxContainer/TextureRectRight
@onready var characterTexRectLeft2 = $HBoxContainer/TextureRectLeft2
@onready var characterTexRect2 = $TextureRect2
@onready var loadingScreen = preload("res://Scenes/Menus/LoadingScreen.tscn")


func _ready():
	controlDetect()
	Conductor.inputChange.connect(controlDetect)
	$ColorRect/LoadingCircle.show()
	SpeedrunTimer.loading = true
	animPlayer2.play("barShowUp")
	var character_list_resource = ResourceLoader.load(CHARACTER_LIST_PATH)
	if character_list_resource:
		characters = character_list_resource.characters
	else:
		print("Failed to load character list resource")
	update_texture_rects()
	characterTexRect2.texture = load(characters[1].portrait_path)
	backCharaColor.frame = selectedIndex
	goToTutorial = CharaHandler.goToTutorial
	for rect in range(textureRects.size()):
		for i in range(numberOfCharacters):
			var palette_path = load("res://Characters/"+ characters[i].character_name + "/Palettes/pal_0.png")

			var mat = textureRects[i+1].get_material()
			mat.set("shader_parameter/palette", palette_path)
			
			var palette_path2 = load("res://Characters/"+ characters[(selectedIndex + characters.size() - 1) % characters.size()].character_name + "/Palettes/pal_0.png")
			var mat2 = textureRects[0].get_material()
			mat.set("shader_parameter/palette", palette_path)
			mat2.set("shader_parameter/palette", palette_path2)
	SpeedrunTimer.loading = false
	$ColorRect/LoadingCircle.hide()

func update_texture_rects():
	# Set the textures of the texture rects based on the character list and the selected character index
	var character_count = characters.size()
	var selected_character = characters[selectedIndex].portrait_path
	textureRects[0].texture = load(characters[(selectedIndex + character_count - 1) % character_count].portrait_path)
	textureRects[1].texture = load(selected_character)
	textureRects[2].texture = load(characters[(selectedIndex + 1) % character_count].portrait_path)
	textureRects[3].texture = load(characters[(selectedIndex + character_count - 1) % character_count].portrait_path)
#	textureRects[4].texture = load(characters[(selectedIndex + 1) % character_count].portrait_path)
	
func update_alt():
	Conductor.menuSelectSfx.play()
	$AltSelector.frame = selectedAlt
	var palette_path = load("res://Characters/"+ characters[selectedIndex].character_name + "/Palettes/pal_"+str(selectedAlt)+".png")
	var mat = characterTexRect.get_material()
	mat.set("shader_parameter/palette", palette_path)

func controlDetect():
	if (Conductor.playingWith == "keyboard"):
		$AltSelector.texture = keybodoTex
	else:
		$AltSelector.texture = controlTex

func _input(event):
	if (canMove):
		if (event.is_action_pressed("altSelectLeft")):
			selectedAlt = (selectedAlt + 4 - 1) % 4
			update_alt()
		if (event.is_action_pressed("altSelectRight")):
			selectedAlt = (selectedAlt + 1) % 4
			update_alt()
		if event.is_action_pressed("menuAccept"):
			canMove = false
			Conductor.menuSelectSfx.play()
			CharaHandler.character = characters[selectedIndex].character_name
			CharaHandler.alt = selectedAlt
			animPlayer2.play("CharacterSelected")
		if event.is_action_pressed("menuGoBack"):
			Conductor.menuGoBack.play()
			hasGoneBack = true
			canMove = false
			animPlayer2.play("CharacterSelected")
		if event.is_action_pressed("ui_right"):
			if (!$AnimationPlayer.is_playing()):
				$AnimationPlayer.play("Scroll")
				selectedIndex = (selectedIndex + 1) % characters.size()
				updateAltTex()
				changeSpr()
		elif event.is_action_pressed("ui_left"):
			if (!$AnimationPlayer.is_playing()):
				$AnimationPlayer.play("ScrollLeft")
				selectedIndex = (selectedIndex + characters.size() - 1) % characters.size()
				updateAltTex()
				changeSpr()
#
func _process(delta):
	waitAbit -= delta
	$ParallaxBackground/ParallaxLayer.motion_offset.x -= 35*delta
	if (waitAbit <= 0):
		if (spd < 2):
			spd = lerp(spd, 2.0, (0.1 * 60) * delta)
		$ParallaxBackground/ParallaxLayer2.motion_offset.x -= (spd*60)*delta

func changeSpr():
	Conductor.menuMoveSfx.play()
	backCharaColor.frame = selectedIndex
	namespr1.frame = selectedIndex
	namespr2.frame = selectedIndex
	namespr3.frame = selectedIndex
	animPlayer2.play("nameChange")

func tutorialStageLoad():
	var instance = loadingScreen.instantiate()
	
	instance.scene = "res://Stages/World_Tutorial/TUTORIAL.tscn"
	instance.worldManager = "res://Scripts/WorldControllers/TUTORIAL_manager.tres"
	if (CharaHandler.character != "May"):
		instance.level = "1"
	else:
		instance.level = "2"
	call_deferred("add_child", instance)

func updateAltTex():
	var character_count = characters.size()
	var palette_path = load("res://Characters/"+ characters[selectedIndex].character_name + "/Palettes/pal_"+str(selectedAlt)+".png")
	var palette_path2 = load("res://Characters/"+ characters[(selectedIndex + character_count - 1) % character_count].character_name + "/Palettes/pal_0.png")
	var mat = characterTexRect.get_material()
	var mat2 = textureRects[0].get_material()
	mat.set("shader_parameter/palette", palette_path)
	mat2.set("shader_parameter/palette", palette_path2)
	
	var palette_path3 = load("res://Characters/"+ characters[(selectedIndex + 1) % character_count].character_name + "/Palettes/pal_0.png")
	var mat3 = textureRects[2].get_material()
	mat3.set("shader_parameter/palette", palette_path3)

func _on_animation_player_2_animation_finished(anim_name):
	if (anim_name == "barShowUp"):
		if (!canMove):
			canMove = true
	elif (anim_name == "CharacterSelected"):
		if (hasGoneBack):
			CharaHandler.goToTutorial = false
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		else:
			if (goToTutorial):
				tutorialStageLoad()
			else:
				get_tree().change_scene_to_file("res://Scenes/Menus/WorldSelect.tscn")
