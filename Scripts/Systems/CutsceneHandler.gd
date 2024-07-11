extends Node

signal dialogueEndedSignal
signal cutsceneDialogueEndedSignal
signal cutsceneSkipSignal
signal shockWaveSignal

var inCutscene = false
var snowCutscene = false
var arenaPreparation = false
var leftPressed = false
var rightPressed = false
var jumpPress = false
var volumeTimer = 3
var npcCurrentlySpeaking = ""
var shouldSkipCutscene = true

func _process(_delta):
	if (inCutscene):
		if snowCutscene:
			SnowAreaCutscene()
	if (arenaPreparation):
		arenaPreparationFunc()

func SnowAreaCutscene():
	if (!inCutscene):
		inCutscene = true
	else:
		if volumeTimer > 0:
			Conductor.volume_db -= get_process_delta_time() * 60
			volumeTimer -= get_process_delta_time()

func arenaPreparationFunc():
	if volumeTimer > 0:
		Conductor.volume_db -= get_process_delta_time() * 60
		volumeTimer -= get_process_delta_time()	
