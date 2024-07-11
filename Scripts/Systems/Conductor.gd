extends AudioStreamPlayer

signal beatSignal
signal fourthSignal
signal beatSignalBPM
signal resetSignal
signal destroyNotes
signal inputChange
signal windowFreezeDetect

signal just_Signal
signal miss_Signal
signal noteBeatSignal
signal noteBeatSignalEarly

signal disableChartDisplay

var playingWith = "keyboard"
var songChart = null
var levelFinished = false
var songToStream = null
var songPosition = 0.0
var bpm = 135
var barBeats = 4
var crotchet = 60/float(bpm)
var songReady = false
var lastBeat = 0
var trueLastBeat = 0
var currentBeat = 1
var safeZoneDuration = 0.3
var safeZonePercent = 80.0
var safe = false
var comparer = 0.0
var comparer2  = 0.0
var securezone = true
var comparer_behind = 0.00
var comparer_front = 0.00
var safedata
var beatCounter = 0
var lastSongPos = 0.0
var lastFourBeats
var combo = 0
var physicsSpeedMultiplier = 1
var singleFramephysicsSpeedMultiplier = 1
var prepareToLoop = false
var player = null
var sceneName = ""

var songSections = []
var currSection = 0
var goToNextSection = true
var waitUp = false
var stopSoundEffects = false
var fourthBeat = 1
var bpm_changed = false
var currentNote = 0
var globalTimeScale = 1.0
var lastNoteTime = 0.0
var safeZoneValue = false
var nextNoteTime = 0.0
var currentNoteTime = 0.0
var currentSpawn = 0
var songLength = 0.0
var timerClock = 0.0
var time_begin
var time_delay
var inanothertab = false
var gamePaused = false
var gameReady = false
var loading = false
var canEnterDebugMenu = true

var tabcheat_callback = JavaScriptBridge.create_callback(_on_tab_cheat)
var focuscheat_callback = JavaScriptBridge.create_callback(_on_focus_cheat)

@onready var metronome = $Metronome
@onready var menuMoveSfx = $MenuMove
@onready var menuSelectSfx = $MenuSelect
@onready var menuGoBack = $MenuSelect2
@onready var tutorialSong = preload("res://Music/mus_tutorialNEW.ogg")
@onready var bpmSync = preload("res://Scenes/HUD/ChartDisplay.tscn")
@onready var menuSong = preload("res://Music/mus_mainmenuNew.ogg")

func _on_tab_cheat(_event):
	if (sceneName == "MainMenu" or sceneName == "WorldSelect" or sceneName == "CharacterSelect"):
		if (!loading):
			if (!stream_paused):
				inanothertab = true
				stream_paused = true
			else:
				if (!gamePaused):
					inanothertab = false
					stream_paused = false
	
func _on_focus_cheat(_event):
	get_tree().paused = true

func _ready():
	if (OS.get_name() == "Web"):
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", tabcheat_callback) 
#
#func _notification(what):
	#if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		#get_tree().paused = false
	#elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		#get_tree().paused = true


func _process(_delta):
	#if (Input.is_action_just_pressed("debugMenuGoTo") and canEnterDebugMenu):
		#get_tree().change_scene_to_file("res://Scenes/Menus/debugMenu.tscn")
		#songUnload()
		#songReset()
		#loopSongReload()
		#CharaHandler.effectsEnabled = true
		#CharaHandler.beatHitsEnabled = true
		#CharaHandler.rhythmSystemEnable = true
	if (!loading):
		if (songReady and !playing) and !get_tree().paused:
			if (sceneName == "MainMenu" or sceneName == "WorldSelect" or sceneName == "CharacterSelect"):
				loopSongReload()
			else:
				if (gameReady):
					loopSongReload()

		songPosition = get_playback_position() + AudioServer.get_time_since_last_mix()
		#songPosition -= AudioServer.get_output_latency()
			
		if ( songPosition  > lastBeat + crotchet) and playing:
			if (!songSections.is_empty()):
				if (fourthBeat == 4 and goToNextSection):
					if !waitUp:
						currSection += 1
						goToNextSection = false
						
			lastBeat += crotchet
			trueLastBeat += crotchet
			currentBeat += 1
			beatCounter += 1
			fourthBeat += 1 
			if fourthBeat >= 5:
				waitUp = false
				fourthBeat = 1
			if beatCounter > 8:
				beatCounter = 1
			emit_signal("beatSignalBPM")
			if (currentBeat % 4 == 0):
				emit_signal("fourthSignal")
			if (currentBeat % 2 == 0):
				emit_signal("beatSignal")
				if (combo >= 7):
					if (!stopSoundEffects):
						if (songPosition < stream.get_length() - crotchet):
							$HeyChant.play()

func songToLoad(songBpm, volume, song):
	prepareToLoop = false
	songToStream = song
	bpm = songBpm
	volume_db = volume
	crotchet = 60/float(songBpm)
	trueLastBeat = -crotchet
	if (sceneName != "MainMenu"):
		levelFinished = false
		spawner(-1)
	else:
		songReady = true

func songUnload():
	stop()
	songToStream = null
	currentBeat = 1
	songReady = false
	lastBeat = 0
	trueLastBeat = 0
	comparer_behind = 0.00
	comparer_front = 0.00
	beatCounter = 0
	safe = false
	comparer = 0.0
	comparer2  = 0.0
	currentSpawn = 0

func songReset():
	currentSpawn = 0
	stop()
	bpm = 135
	crotchet = 60/float(bpm)
	combo = 0
	fourthBeat = 1
	currentBeat = 1
	lastSongPos = 0.0
	lastBeat = 0
	trueLastBeat = 0
	comparer_behind = 0.00
	comparer_front = 0.00
	beatCounter = 0
	safe = false
	comparer = 0.0
	comparer2  = 0.0

func loopSongReload():
	if songSections.is_empty():
		#si no hay secciones loopear la canción normalmente de inicio a fin
		set_stream(songToStream)
	else:
		#la sección se va a loopear hasta que la variable goToNextSection sea true o el archivo que 
		#se esté reproduciendo sea un intro o una transición, así que no hay necesidad
		#de cambiar esta parte
		set_stream(songSections[currSection])
		var strimpath = songSections[currSection].resource_path
		
		if (goToNextSection) or ((strimpath.ends_with("intro.ogg") or strimpath.ends_with("Transition.ogg"))):
			print(strimpath)
			currSection += 1
			print("has gone to next section")
			goToNextSection = false
	play()
	if (combo >= 7):
		if (!stopSoundEffects):
			$HeyChant.play()
	lastBeat = 0
	print(songToStream)
	trueLastBeat = -crotchet
	emit_signal("beatSignal")
	emit_signal("beatSignalBPM")
	currentBeat = 1
	fourthBeat = 1
	currentBeat += 1
	beatCounter = 1
	if beatCounter > 8:
		beatCounter = 1
	emit_signal("resetSignal")

func spawner(audioPlayerID):
	currentSpawn += 1
	if sceneName != "MainMenu" or sceneName != "WorldSelect":
		var id = bpmSync.instantiate()
		id.audioPlayerID = audioPlayerID + 1
		add_child(id)
		id.layer -= 1

func _exit_tree():
	queue_free()
	tutorialSong = null
	menuMoveSfx.queue_free()
	metronome.queue_free()
	menuSelectSfx.queue_free()

#FUCK HTML5 WE HATE HTML5 FUCK 
func resetEVERYTHING():
	playingWith = "keyboard"
	songChart = null
	levelFinished = false
	bpm = 135
	barBeats = 4
	crotchet = 60/float(bpm)
	songReady = true
	lastBeat = 0
	trueLastBeat = 0
	currentBeat = 1
	safeZoneDuration = 0.3
	safeZonePercent = 80.0
	safe = false
	comparer = 0.0
	comparer2  = 0.0
	securezone = true
	comparer_behind = 0.00
	comparer_front = 0.00
	beatCounter = 0
	lastSongPos = 0.0
	combo = 0
	physicsSpeedMultiplier = 1
	singleFramephysicsSpeedMultiplier = 1
	prepareToLoop = false
	player = null
	sceneName = ""
	songSections = []
	currSection = 0
	goToNextSection = true
	waitUp = false
	stopSoundEffects = false
	fourthBeat = 1
	bpm_changed = false
	currentNote = 0
	globalTimeScale = 1.0
	lastNoteTime = 0.0
	safeZoneValue = false
	nextNoteTime = 0.0
	currentNoteTime = 0.0
	currentSpawn = 0
	songLength = 0.0
	timerClock = 0.0
	inanothertab = false
	gamePaused = false
