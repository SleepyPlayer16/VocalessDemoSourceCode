extends CanvasLayer

@export var songName = ""
@export var authorName = ""

func _ready():
	$Card/SongName.text = songName
	$Card/Author.text = authorName


func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Enter"):
		$AnimationPlayer.play("Exit")
	if (anim_name == "Exit"):
		queue_free()
