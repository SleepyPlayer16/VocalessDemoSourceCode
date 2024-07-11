extends Resource
class_name SongList

const CHARACTER_LIST = [
	{
		"character_name": "",
	}
]

@export var characters : Array

func _init(charas_ = CHARACTER_LIST):
	characters = charas_
