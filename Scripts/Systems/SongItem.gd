extends Sprite2D

@onready var txt = $Time.text
@onready var ranking = $SprRankings
var levelFinished = false
var score = -9000000

func _process(_delta):
	if (score != -9000000):
		if score >= 9500:
			ranking.frame = 0
		elif score < 9500 and score >= 9000:
			ranking.frame = 1
		elif score < 9000 and score >= 7800:
			ranking.frame = 2
		elif score < 7800 and score >= 6500:
			ranking.frame = 3
		elif score < 6500 and score >= 5000:
			ranking.frame = 4
		elif score < 6500 and score > 0:
			ranking.frame = 5
		elif score <= 0:
			if (!levelFinished):
				ranking.frame = 6
			else:
				ranking.frame = 5

func _exit_tree():
	queue_free()

func _format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
