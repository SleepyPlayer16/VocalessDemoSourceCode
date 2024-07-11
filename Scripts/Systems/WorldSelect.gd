extends Node2D

const ARROW_PRESSED_Y = 290
const ARROW_DEFAULT_Y = 286
const WORLD_SELECT_TEXT_FINAL_POS = 16
const WORLD_SELECT_TEXT_INITIAL_POS = -432
const SCROLL_SPEED = 0.1
const LEVEL_POS_Y = 90
const LEVEL_BUTTON_SCROLL_SPEED = 0.2

var timerTweenErrorPrevent = 0
@onready var pathToImageTexture = "res://Stages/"
@onready var getReadyToLoad = false

@onready var worldMenuNode = $WorldMenu
@onready var backgroundPic = [
	
	$LvlBackgrounds/SkyNoMountains, 
	$LvlBackgrounds/SprDragoniaBack, 
	$LvlBackgrounds/SprFrostfallBack, 
	$LvlBackgrounds/SprJetCityBack
]
@onready var arrowSprites = [$WorldMenu/SprArrow, $WorldMenu/SprArrow2]
@onready var worldSprite = $WorldMenu/SprWorlds
@onready var nameSprite = $WorldMenu/SprWorldNamesEn
@onready var worldBackColor = $WorldMenu/SprWorldBackColorThing
@onready var worldSelectText = $SprWorldSelect
@onready var levelSelectText = $SprLevelSelect
@onready var songItemNode = $LevelSelect
@onready var animPlayer = $AnimationPlayer


@onready var songItemScene = preload("res://Scenes/Menus/SongItem.tscn")
@onready var loadingScreen = preload("res://Scenes/Menus/LoadingScreen.tscn")
@onready var menuSong = preload("res://Music/mus_mainmenuNew.ogg")
@onready var controlTex = preload("res://Sprites/Menu/spr_difficultiesCtr.png")
@onready var keybodoTex = preload("res://Sprites/Menu/spr_difficulties.png")

var tweenCreate = false
var selectedWorld = world.SOLAR_CITY
var worldCount = world.JET_CITY + 1
var currentMenu = 0
var menu_transitioning = false
var running_tweens = []
var loading = false
var goingback = false
var difficulty

var selectedLevel = 0
var textures = {}
var levelScore = []
var texture_array = []

enum world {
	SOLAR_CITY,
	DRAGONIA_FOREST,
	FROSTFALL,
	JET_CITY
}

var world_levels = {
	"SOLAR_CITY": 1,
	"DRAGONIA_FOREST": 1,
	"FROSTFALL": 2,
	"JET_CITY": 1,
}

var levelQuantity = world_levels[world.keys()[selectedWorld]]

func _ready():
	controlDetect()
	Conductor.inputChange.connect(controlDetect)
	$ColorRect/LoadingCircle.show()
	if CharaHandler.difficulty == CharaHandler.difficulties.NORMAL:
		difficulty = "normal"
	else:
		difficulty = "hard"
	SpeedrunTimer.loading = true
	RankingSystemSave.recreateData()
	for world_name in world_levels.keys():
		var world_textures = {}
		for i in range(1, world_levels[world_name]+1):
			var texture_path = "res://Stages/" + world_name + "/data/" + str(i) + ".png"
			var texture = load_texture(texture_path)
			world_textures[i] = texture
			textures[world_name] = world_textures
	update_world_sprite()
	animPlayer.play("EnterScene")
	SpeedrunTimer.loading = false
	
	if !Conductor.playing:
		Conductor.songToLoad(125,-3,menuSong)
		Conductor.emit_signal("destroyNotes")
		Conductor.songReady = true
	$ColorRect/LoadingCircle.hide()
	
func _process(delta):
	if timerTweenErrorPrevent > 0:
		timerTweenErrorPrevent -= delta
	if (currentMenu == 0 and !loading and !goingback):
		if (Input.is_action_just_pressed("menuGoBack")):
			timerTweenErrorPrevent = 999
			goingback = true
			Conductor.menuGoBack.play()
			animPlayer.play("ExitScene")
		if Input.is_action_just_pressed("altSelectLeft") or Input.is_action_just_pressed("altSelectRight"):
			Conductor.menuMoveSfx.play()
			if CharaHandler.difficulty == CharaHandler.difficulties.NORMAL:
				difficulty = "hard"
				CharaHandler.difficulty = CharaHandler.difficulties.HARD
			else:
				difficulty = "normal"
				CharaHandler.difficulty = CharaHandler.difficulties.NORMAL
		
		$SprDifficulties.visible = true
		$SprDifficulties.frame = CharaHandler.difficulty
		worldSelectText.position.x = lerp(worldSelectText.position.x, float(WORLD_SELECT_TEXT_FINAL_POS), (SCROLL_SPEED*60)*delta)
		levelSelectText.position.x = lerp(levelSelectText.position.x, float(WORLD_SELECT_TEXT_INITIAL_POS), (SCROLL_SPEED*60)*delta)
		nameSprite.frame = worldSprite.frame
		worldBackColor.frame = worldSprite.frame
		
		if Input.is_action_just_pressed("ui_right"):
			Conductor.menuMoveSfx.play()
			selectedWorld = (world.values()[(selectedWorld + 1) % worldCount]) 
			update_world_sprite()
		elif Input.is_action_just_pressed("ui_left"):
			Conductor.menuMoveSfx.play()
			selectedWorld = (world.values()[((selectedWorld - 1) + worldCount) % worldCount ]) 
			update_world_sprite()
		set_arrow_position(Input.is_action_pressed("ui_right"), Input.is_action_pressed("ui_left"))

		if (Input.is_action_just_pressed("menuAccept") and timerTweenErrorPrevent <= 0):
			Conductor.menuSelectSfx.play()
			timerTweenErrorPrevent = 0.1
			selectedLevel = 0
			menu_transitioning = true
			currentMenu = 1
			$SprDifficulties.visible = false
			call_deferred("instantiateSongItems")
			#instantiateSongItems()
			worldMenuNode.hide()
	elif currentMenu == 1 and !loading:
		worldSelectText.position.x = lerp(worldSelectText.position.x, float(WORLD_SELECT_TEXT_INITIAL_POS), (SCROLL_SPEED*60)*delta)
		levelSelectText.position.x = lerp(levelSelectText.position.x, float(WORLD_SELECT_TEXT_FINAL_POS), (SCROLL_SPEED*60)*delta)
		
		if songItemNode.get_child_count() > 0:
			if !tweenCreate:
				tweenCreate = true
				for i in range(songItemNode.get_child_count()):
					tweenSongs(i, songItemNode.get_child(i))
		
		if (Input.is_action_just_pressed("ui_down")):
			Conductor.menuMoveSfx.play()
			songItemNode.get_child(selectedLevel).get_node("ColorRect").hide()
			songItemNode.get_child(selectedLevel).frame = 1
			selectedLevel = (selectedLevel + 1) % levelQuantity
			buttonChangeSelected(selectedLevel, songItemNode.get_child(selectedLevel))
		if (Input.is_action_just_pressed("ui_up")):
			Conductor.menuMoveSfx.play()
			songItemNode.get_child(selectedLevel).get_node("ColorRect").hide()
			songItemNode.get_child(selectedLevel).frame = 1
			selectedLevel = (selectedLevel - 1) % levelQuantity
			buttonChangeSelected(selectedLevel, songItemNode.get_child(selectedLevel))
		if (Input.is_action_just_pressed("menuGoBack") and timerTweenErrorPrevent <= 0):
			timerTweenErrorPrevent = 0.1
			currentMenu = 0
			Conductor.menuGoBack.play()
			worldMenuNode.show()
			menu_transitioning = true
			removeSongItems()
	if (Input.is_action_just_pressed("menuAccept")):
		if (!menu_transitioning):
			if (!loading):
				timerTweenErrorPrevent = 999
				Conductor.menuSelectSfx.play()
				instantiateLevelSelect_load()
	if (menu_transitioning):
		menu_transitioning = false

func set_arrow_position(is_right_pressed, is_left_pressed):
	if is_right_pressed and is_left_pressed:
		for arrow_sprite in arrowSprites:
			if arrow_sprite:
				arrow_sprite.position.y = ARROW_DEFAULT_Y
	else:
		for arrow_sprite in arrowSprites:
			if arrow_sprite:
				if is_right_pressed and arrow_sprite == $WorldMenu/SprArrow:
					arrow_sprite.position.y = ARROW_PRESSED_Y
				elif is_left_pressed and arrow_sprite == $WorldMenu/SprArrow2:
					arrow_sprite.position.y = ARROW_PRESSED_Y
				else:
					arrow_sprite.position.y = ARROW_DEFAULT_Y

func controlDetect():
	if (Conductor.playingWith == "keyboard"):
		$SprDifficulties.texture = keybodoTex
	else:
		$SprDifficulties.texture = controlTex

func update_world_sprite():
	match selectedWorld:
		world.SOLAR_CITY:
			change_frame(0)
		world.DRAGONIA_FOREST:
			change_frame(1)
		world.FROSTFALL:
			change_frame(2)
		world.JET_CITY:
			change_frame(3)

	levelQuantity = world_levels[world.keys()[selectedWorld]]

func change_frame(frameNum):
	backgroundPic[worldSprite.frame].hide()
	worldSprite.frame = frameNum
	backgroundPic[worldSprite.frame].show()	

func instantiateSongItems():
	for i in range(levelQuantity):
		loadScore(i)
		var levelButton = songItemScene.instantiate()
		levelButton.set_name("LevelButton" + str(i+1))
		songItemNode.add_child(levelButton)
		levelButton.get_node("Deaths").text = str(levelScore[i]["deaths"])
		levelButton.get_node("Parries").text = str(levelScore[i]["parries"])
		levelButton.score = float(levelScore[i]["score"])
		levelButton.levelFinished = levelScore[i]["cleared"]
		levelButton.get_node("Time").text = levelButton._format_seconds(levelScore[i]["time"], false)
		if (selectedLevel == i):
			levelButton.get_node("ColorRect").show()
			levelButton.frame = 0
		else:
			levelButton.frame = 1
		levelButton.get_node("SprLevelNumbers").frame = i
		levelButton.position.y = float(get_viewport_rect().size.y) # Start at the bottom of the screen

		levelButton.get_node("SprLevelName").texture = textures[world_levels.keys()[selectedWorld]][i+1]

func buttonChangeSelected(levelNum, level):
		if (selectedLevel == levelNum):
			level.get_node("ColorRect").show()
			level.frame = 0

func on_tween_completed(tween: Tween) -> void:
	print("asdpklfjd")
	tween.queue_free()

func tweenSongs(i, item):
	var levelButton = item
	await get_tree().create_timer(i * 0.1).timeout
	var tween = get_tree().create_tween()
	if tween != null:
		tween.tween_callback(tween.play)
		tween.tween_property(levelButton, "position:y",float(i * LEVEL_POS_Y), float(LEVEL_BUTTON_SCROLL_SPEED))
		print(tween)

func removeSongItems():
	tweenCreate = false
	levelScore = []
	for i in songItemNode.get_children():
		songItemNode.remove_child(i)
		
func load_texture(path):
	var resource = ResourceLoader.load(path)
	return resource

func instantiateLevelSelect_load():
	loading = true
	print("loading level now...")
	var instance = loadingScreen.instantiate()
	
	instance.scene = "res://Stages/" + world_levels.keys()[selectedWorld] + "/" + world_levels.keys()[selectedWorld] + "_" + str(selectedLevel+1) + ".tscn"
	instance.worldManager = "res://Scripts/WorldControllers/" + world_levels.keys()[selectedWorld] + "_manager.tres"
	instance.level = str(selectedLevel+1)
	call_deferred("add_child",instance)

func loadScore(level):
	var save = str("user://Scores/" + CharaHandler.character + "/rankings/" + world_levels.keys()[selectedWorld] + "/level" + str(level+1) + "-" + difficulty + ".json")

	if FileAccess.file_exists(save):

		var file = FileAccess.open(save, FileAccess.READ)
		var stringFile = file.get_as_text()
		var dict = JSON.parse_string(stringFile)
		levelScore.append(dict)
	else:
		print("file not found")


func _exit_tree():
	texture_array.clear()
	textures.clear()
	for i in songItemNode.get_children():
		songItemNode.remove_child(i)
		i.queue_free()
	songItemNode.queue_free()

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "ExitScene"):
		get_tree().change_scene_to_file("res://Scenes/Menus/CharacterSelect.tscn")
