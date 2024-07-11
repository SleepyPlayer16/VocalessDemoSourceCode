extends Node

const CHARACTER_LIST_PATH = "res://Characters/CharacterList.tres"
var characters = []

var world_levels = {
	"SOLAR_CITY": 1,
	"DRAGONIA_FOREST": 1,
	"FROSTFALL": 2,
	"JET_CITY": 1,
	"TUTORIAL": 1,
}

var world_data = {
	"deaths": 0,
	"parries": 0,
	"time": 0,
	"score": 0,
	"cleared": false
}

var deaths = 9
var firstDeath = 0
var parries =  0
var totalParries = 3
var time = 120
var totalstagetime = 120

func _ready():
	var character_list_resource = ResourceLoader.load(CHARACTER_LIST_PATH)
	if character_list_resource:
		characters = character_list_resource.characters
		
	for world_name in world_levels.keys():
		for i in range(world_levels[world_name]):
			for e in characters:
				save_rankings(e["character_name"], world_name, i+1, world_data)

func recreateData():
	var character_list_resource = ResourceLoader.load(CHARACTER_LIST_PATH)
	if character_list_resource:
		characters = character_list_resource.characters
		
	for world_name in world_levels.keys():
		for i in range(world_levels[world_name]):
			for e in characters:
				save_rankings(e["character_name"], world_name, i+1, world_data)

func save_rankings(character_name: String, world_name: String, level_number: int, data: Dictionary):
	var dir = "user://Scores/" + character_name + "/rankings/" + world_name
	var fileEasy = dir + "/level" + str(level_number) + "-normal.json"
	var fileHard = dir + "/level" + str(level_number) + "-hard.json"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var file_access_easy = FileAccess
	if (!file_access_easy.file_exists(fileEasy)):
		var json = JSON.stringify(data)
		var file_handle = FileAccess.open(fileEasy, FileAccess.WRITE)
		if file_handle != null:
			file_handle.store_string(json)
			file_handle.close()
		else:
			print("Failed to open file: ", fileEasy)

	var file_access_hard = FileAccess
	if (!file_access_hard.file_exists(fileHard)):
		var json = JSON.stringify(data)
		var file_handle = FileAccess.open(fileHard, FileAccess.WRITE)
		if file_handle != null:
			file_handle.store_string(json)
			file_handle.close()
		else:
			print("Failed to open file: ", fileHard)
#	else:
#		print("already exists bitch")
