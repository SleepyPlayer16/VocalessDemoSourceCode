extends CanvasLayer

var deaths = 0
var firstDeath = 0
var parries = 0
var timeElapsed = 0.0
var totalParries = CharaHandler.idealParries
var parryScore = 550
var totalstagetime = CharaHandler.idealTime
var combo = 0
var difficulty = ""
var score
@onready var deathText = $RankStuff/Deaths
@onready var parriesText = $RankStuff/Parries
@onready var timeText = $RankStuff/Time
@onready var portrait = $Character
@onready var palette
@onready var resMusic = $results
var saved = false
var levelScore = []
var rank
var rankNumber = 0
var exiting = false

var tabcheat_callback = JavaScriptBridge.create_callback(_on_tab_cheat)
var focuscheat_callback = JavaScriptBridge.create_callback(_on_focus_cheat)

func _on_tab_cheat(_event):
	#get_tree().paused = true
	if (!resMusic.stream_paused):
		resMusic.stream_paused = true
	else:
		resMusic.stream_paused = false
	
func _on_focus_cheat(_event):
	get_tree().paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if (OS.get_name() == "Web"):
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", tabcheat_callback) 
	deathText.text = str(deaths + firstDeath)
	parriesText.text = str(parries) + "/" + str(totalParries)
	timeText.text = _format_seconds(timeElapsed, false)
	var timePenaltyLoss = max((timeElapsed - totalstagetime) * 35, 0)
	var deathPunishment = deaths*70
	var firstDeathPunishment = firstDeath * 650
	var parryCalculation = (parryScore*parries)
	loadScore(int(CharaHandler.level), CharaHandler.difficulty)
	$Character.get_material().set("shader_parameter/palette", load("res://Characters/"+ CharaHandler.character + "/Palettes/pal_"+str(CharaHandler.alt)+".png"))
	score = (((10000-(parryScore*totalParries)) + parryCalculation) - ( firstDeathPunishment + deathPunishment)) - timePenaltyLoss
	if score >= 9500:
		rank = "S+"
		rankNumber = 5
	elif score < 9500 and score >= 9000:
		rank = "S"
		rankNumber = 4
	elif score < 9000 and score >= 7800:
		rank = "A"
		rankNumber = 3
	elif score < 7800 and score >= 6500:
		rank = "B"
		rankNumber = 2
	elif score < 6500 and score >= 5000:
		rank = "C"
		rankNumber = 1
	elif score < 6500:
		rank = "D"
		rankNumber = 0

	get_node("RankStuff/rankingBack_" + rank).visible = true
	var world_data = {
		"deaths": deaths + firstDeath,
		"parries": parries,
		"time": timeElapsed,
		"score": score,
		"cleared": true
	}
	save_rankings(CharaHandler.character, get_tree().current_scene.name, int(CharaHandler.level), world_data, CharaHandler.difficulty)
	
func _process(delta):
	if rank == "C" or rank == "D":
		if $results.pitch_scale > 0.65 and $results.get_playback_position() > 1.95:
			$results.pitch_scale -= (0.01*60*delta)
	if exiting:
		$results.volume_db -= delta*60
	if (Input.is_action_just_pressed("ui_accept")):
		if (!exiting):
			Conductor.menuSelectSfx.play()
			exiting = true
	#print("score:", score)
	#print("score + time elapsed:", score + timeElapsed)
	#print("levelScore:", levelScore[0]["score"] + timeElapsed)

func _format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func loadScore(level, diff):
	if diff == CharaHandler.difficulties.NORMAL:
		diff = "-normal"
	else:
		diff = "-hard"
	var save = str("user://Scores/" + CharaHandler.character + "/rankings/" + get_tree().current_scene.name + "/level" + str(level) + diff + ".json")
	if FileAccess.file_exists(save):

		var file = FileAccess.open(save, FileAccess.READ)
		var stringFile = file.get_as_text()
		var dict = JSON.parse_string(stringFile)
		levelScore.append(dict)
	else:
		print("file not found")

func save_rankings(character_name: String, world_name: String, level_number: int, data: Dictionary, diff):
	if diff == CharaHandler.difficulties.NORMAL:
		diff = "-normal"
	else:
		diff = "-hard"

	var dir = "user://Scores/" + character_name + "/rankings/" + world_name
	var file = dir + "/level" + str(level_number) + diff +".json"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	if !levelScore.is_empty():
		#Checks if the stage has been cleared by the player before, if not then force a save 
		#(if i dont do this, the time calculations below fuck with the save system causing a mess)
		if levelScore[0]["cleared"] == false:
			var json = JSON.stringify(data)
			var file_handle = FileAccess.open(file, FileAccess.WRITE)
			if file_handle != null:
				file_handle.store_string(json)
				file_handle.close()
				$AnimationPlayer2.play("newRecord")
			else:
				print("Failed to open file: ", file)
		else:
			if (score - timeElapsed) > levelScore[0]["score"] - levelScore[0]["time"]:
				#if timeElapsed < levelScore[0]["time"]:
				var json = JSON.stringify(data)
				var file_handle = FileAccess.open(file, FileAccess.WRITE)
				if file_handle != null:
					file_handle.store_string(json)
					file_handle.close()
					$AnimationPlayer2.play("newRecord")
				else:
					print("Failed to open file: ", file)
			else:
				#do literally nothing bitch
				print("lower score")
				pass
	else:
		var json = JSON.stringify(data)
		var file_handle = FileAccess.open(file, FileAccess.WRITE)
		if file_handle != null:
			file_handle.store_string(json)
			file_handle.close()
		else:
			print("Failed to open file: ", file)
		print("save data not found wtf!!! creating new data instantly")
