extends Node2D

var playerHasEntered = false
@onready var rankScene = preload("res://Scenes/HUD/levelResults.tscn")

func _process(delta):
	
	if (playerHasEntered):
		Conductor.volume_db = clamp(Conductor.volume_db - ((0.5*60)*delta), -80, 0)

func _on_area_2d_body_entered(body):
	if (body.name == "PlayerObject"):
		if (!playerHasEntered):
			call_deferred("spawnRanking", body.deaths, body.parries, body.timeElapsed, body.characterPortrait, body.firstDeath)
			#spawnRanking(body.deaths, body.parries, body.timeElapsed, body.characterPortrait, body.firstDeath)
			playerHasEntered = true
			body.win = true

func spawnRanking(deaths, parries, time, portrait, firstdeath):
	var rankSceneId
	rankSceneId = rankScene.instantiate()
	rankSceneId.deaths = deaths
	rankSceneId.firstDeath = firstdeath
	rankSceneId.parries = parries
	rankSceneId.timeElapsed = time
	
	add_child(rankSceneId)
	rankSceneId.portrait.texture = portrait
	#call_deferred("add_child", rankSceneId)
