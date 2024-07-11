extends Node

var world_data = {}

func _ready():
	var custom_resource = ResourceLoader.load("res://Scripts/WorldControllers/SolarCityRes.tres")
	
	if custom_resource != null:
		# Store the data in the dictionary
		world_data["level_one_song"] = custom_resource.level_one_song
		world_data["level_one_bpm"] = custom_resource.level_one_bpm
		world_data["level_two_song"] = custom_resource.level_two_song
		world_data["level_two_bpm"] = custom_resource.level_two_bpm
		world_data["level_three_song"] = custom_resource.level_three_song
		world_data["level_three_bpm"] = custom_resource.level_three_bpm
		world_data["level_boss_song"] = custom_resource.level_boss_song
		world_data["level_boss_bpm"] = custom_resource.level_boss_bpm
