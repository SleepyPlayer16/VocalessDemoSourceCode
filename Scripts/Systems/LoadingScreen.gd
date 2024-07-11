extends Node


var scene:String = ""
var worldManager:String = ""
var level:String = ""

@onready var progressBar:ProgressBar = $ProgressBar

var progress = []
var scene_load_status = 0
var timer = .2
var world_data = {}
var character_data = {}
var beginLoading = false
var readyTogo = false
@onready var loadingCharaSprite = $ProgressBar/AnimatedSprite2D 

func _ready():
	Conductor.loading = true
	Conductor.resetEVERYTHING()
	Conductor.songPosition = 0.0
	SpeedrunTimer.loading = true
	var mat = load("res://Characters/"+ CharaHandler.character + "/Palettes/pal_"+str(CharaHandler.alt)+".png")
	loadingCharaSprite.get_material().set("shader_parameter/palette", mat)
	if (CharaHandler.character != "Karu"):
		loadingCharaSprite.play(CharaHandler.character)

func _process(delta):
	if (Conductor.volume_db) > -80.0:
		Conductor.volume_db -= (3.5 * 60) * delta
	else:
		if Conductor.playing:
			Conductor.stop()
	if $AnimationPlayer.get_current_animation_position() >= 1:
		if (!beginLoading):
			beginLoading = true
			#load the mangaer for the selected world
			var custom_resource = ResourceLoader.load(worldManager)
			if custom_resource != null:
				world_data["level_1_song"] = custom_resource.level_one_song
				world_data["level_1_chart"] = custom_resource.level_one_chart
				world_data["level_1_hardChart"] = custom_resource.level_one_hardChart
				world_data["level_1_bpm"] = custom_resource.level_one_bpm
				world_data["level_1_idealTime"] = custom_resource.level_one_idealTime
				world_data["level_1_idealParries"] = custom_resource.level_one_idealParries

				world_data["level_2_song"] = custom_resource.level_two_song
				world_data["level_2_chart"] = custom_resource.level_two_chart
				world_data["level_2_hardChart"] = custom_resource.level_two_hardChart
				world_data["level_2_bpm"] = custom_resource.level_two_bpm
				world_data["level_2_idealTime"] = custom_resource.level_two_idealTime
				world_data["level_2_idealParries"] = custom_resource.level_two_idealParries

				world_data["level_3_song"] = custom_resource.level_three_song
				world_data["level_3_chart"] = custom_resource.level_three_chart
				world_data["level_3_hardChart"] = custom_resource.level_three_hardChart
				world_data["level_3_bpm"] = custom_resource.level_three_bpm
				world_data["level_3_idealTime"] = custom_resource.level_three_idealTime
				world_data["level_3_idealParries"] = custom_resource.level_three_idealParries

				world_data["level_4_song"] = custom_resource.level_boss_song
				world_data["level_4_chart"] = custom_resource.level_boss_chart
				world_data["level_4_hardChart"] = custom_resource.level_boss_hardChart
				world_data["level_4_bpm"] = custom_resource.level_boss_bpm
				world_data["level_4_idealTime"] = custom_resource.level_boss_idealTime
				world_data["level_4_idealParries"] = custom_resource.level_boss_idealParries

			if CharaHandler.loadChara:
				var charaRes = ResourceLoader.load("res://Characters/" + CharaHandler.character + "/props.tres")
				if charaRes != null:
					character_data["maxWalkVelocity"] = charaRes.maxWalkVelocity
					character_data["jump_velocity"] = charaRes.jump_velocity
					character_data["maxJumps"] = charaRes.maxJumps
					character_data["maxDashDistance"] = charaRes.maxDashDistance
					character_data["character_class"] = charaRes.character_class
					character_data["canWallJump"] = charaRes.canWallJump
					character_data["portrait"] = charaRes.portrait
					character_data["hudPortrait"] = charaRes.hudPortrait
					character_data["phantomColorPalette"] = charaRes.phantomColorPalette
			ResourceLoader.load_threaded_request(scene)

	if beginLoading:
		scene_load_status = ResourceLoader.load_threaded_get_status(scene, progress)
		progressBar.value = lerp(progressBar.value, progress[0] * 100, (0.3*60)*delta) 
		#$ProgressBar/AnimatedSprite2D.position.x = lerp($ProgressBar/AnimatedSprite2D.position.x, $ProgressBar.value*6.65, (0.3*60)*delta)
		$ProgressBar/AnimatedSprite2D.position.x = $ProgressBar.value*6.65
		
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			if !readyTogo:
				readyTogo = true
				$AnimationPlayer.play("Out")
			if $AnimationPlayer.get_current_animation_position() >= 0.8:
				if readyTogo:
					CharaHandler.characterData = character_data
					CharaHandler.characterPortrait = load(character_data["portrait"])
					CharaHandler.characterHudPortrait = load(character_data["hudPortrait"])
					CharaHandler.phantomColor = load(character_data["phantomColorPalette"])
					if (character_data["maxJumps"] == 4):
						CharaHandler.playerHudJumpsNumbah = 4
						#print("FUCK YOU")
						CharaHandler.playerHudJumps = load("res://Sprites/HUD/spr_jumpIndicatorTripleJump.png")
					elif (character_data["maxJumps"] == 3):
						#print("sauoifjhwdsoifdsjpoidsuoijfjdois")
						CharaHandler.playerHudJumpsNumbah = 3
						CharaHandler.playerHudJumps = load("res://Sprites/HUD/spr_jumpIndicator.png")
					elif (character_data["maxJumps"] == 2):
						#print("sauoifjhwdsoifdsjpoidsuoijfjdois")
						CharaHandler.playerHudJumpsNumbah = 2
						CharaHandler.playerHudJumps = load("res://Sprites/HUD/spr_jumpIndicatorSingleJump.png")
					if Conductor.playing:
						Conductor.stop()				
					CharaHandler.playerMaterial = load("res://Characters/"+ CharaHandler.character + "/Palettes/pal_"+str(CharaHandler.alt)+".png")
					CharaHandler.idealTime = world_data["level_"+level+"_idealTime"]
					CharaHandler.idealParries = world_data["level_"+level+"_idealParries"]
					CharaHandler.level = level

					Conductor.stream_paused = false
					Conductor.songUnload()
					Conductor.sceneName = "loading"
					
					Conductor.songToLoad(world_data["level_"+level+"_bpm"], -1,world_data["level_"+level+"_song"])
					if CharaHandler.difficulty == CharaHandler.difficulties.NORMAL:
						Conductor.songChart = world_data["level_"+level+"_chart"]
					else:
						Conductor.songChart = world_data["level_"+level+"_hardChart"]
				
					get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene))

