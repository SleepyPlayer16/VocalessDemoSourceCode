extends CanvasLayer

const BPM = 125
const BARS = 4
const TRUEBPS = 60.0/BPM
const BPS = BPM/60.0

var song_chart = ""

var note = {}
var noteloop = []
var cur_note = 0

var id
var id2
var audioPlayerID = -1
var begin_song = false
var time = 0.0
var number_of_notes = null

var time_of_loop = 0.0
var playing = false
var layerr = -1
const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0
var show_in_advance = 4
var begin_at = null
var newPlayerID = 0

var time_begin2 = 0
var time_delay2 = 0
var currentSpawn = 0
var secondary_time = 0.0
var loopTimer = 0.0

enum SyncSource {
	SYSTEM_CLOCK,
	SOUND_CLOCK,
}

var curr_note_by_time = 0
var curr_noteSingleFrame = 0

var sync_source = SyncSource.SYSTEM_CLOCK

# Used by system clock.
var time_begin
var time_fake = 0.0
var time_delay
var show_notes = 1
var loop = false
var unloop = false
var songLoaded = false
var destructTimer = 1
var prepareForMassDestruction = false
var lastBeat = 0.0
var timeBetween = 0.0

@onready var noteScene = load("res://Scenes/HUD/Note.tscn")
@onready var miniNoteScene = load("res://Scenes/HUD/Note_mini.tscn")
@onready var audioPlayer = $AudioStreamPlayer
@onready var silence = $Silence

var countdown = true
var activateSecondaryTime = false

var tabcheat_callback = JavaScriptBridge.create_callback(_on_tab_cheat)
var focuscheat_callback = JavaScriptBridge.create_callback(_on_focus_cheat)


func _on_tab_cheat(_event):
	if time >= 0.0:
		if (!audioPlayer.stream_paused):
			audioPlayer.stream_paused = true
			Conductor.stream_paused = true
		else:
			if (!Conductor.gamePaused):
				audioPlayer.stream_paused = false
				Conductor.stream_paused = false

	if time < 0.0:
		if !silence.stream_paused:
			silence.stream_paused = true
			Conductor.stream_paused = true
		else:
			if (!Conductor.gamePaused):
				silence.stream_paused = false
				Conductor.stream_paused = false

func _on_focus_cheat(_event):
	get_tree().paused = true

func _ready():
	if (OS.get_name() == "Web"):
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", tabcheat_callback) 
	if (Conductor.currentSpawn <= 1):
		$Strumbar/AnimationPlayer.play("intro")
	else:
		$Strumbar/AnimationPlayer.play("noIntro")
	Conductor.destroyNotes.connect(resetFunc)
	Conductor.disableChartDisplay.connect(disableChartDisplay)
	if !(CharaHandler.rhythmSystemEnable):
		visible = false

func _process(_delta: float):
	if (!Conductor.loading and !silence.playing):
		silence.play()
	if (!Conductor.levelFinished):
		if Conductor.songChart != null:
			if Conductor.stream != null:
				if !songLoaded:
					if Conductor.songToStream != null:
						song_chart = Conductor.songChart
						if song_chart != "":
							initialSetup()
						songLoaded = true
						var songToStream = Conductor.songToStream
						audioPlayer.stream = songToStream

			#if Input.is_action_just_pressed("fastForward"):
				#time = Conductor.songToStream.get_length()-Conductor.crotchet*16
#
				#audioPlayer.play(time)
			if Conductor.playing and begin_song:
				if (audioPlayer.playing):
					time = audioPlayer.get_playback_position() + AudioServer.get_time_since_last_mix()
				else:
					if prepareForMassDestruction:
						time += _delta
				GlobalDelta.globalSongTime = time
			if !begin_song:
				time = $Silence.get_playback_position()-Conductor.crotchet*4 + AudioServer.get_time_since_last_mix()
				GlobalDelta.globalSongTime = time
			if begin_song and unloop:
				time = $Silence.get_playback_position()-Conductor.crotchet*4 + AudioServer.get_time_since_last_mix()

			if time >= 0.0 and !begin_song:
				if ($Silence.playing):
					$Silence.stop()
				if Conductor.songToStream != null:
					Conductor.songReady = true
					Conductor.gameReady = true
				playing = true
				begin_song = true
				Conductor.loopSongReload()
				audioPlayer.play()
			if time >= Conductor.songToStream.get_length()-Conductor.crotchet*4:
				if !loop:
					if cur_note == noteloop.size()-1:
						loop = true
						$Strumbar/Control/RhythmIndicatorBackground.visible = false
						Conductor.spawner(audioPlayerID)
						
						Conductor.prepareToLoop = true
						prepareForMassDestruction = true
			if prepareForMassDestruction:
				destructTimer -= _delta
				if destructTimer <= 0:
		#			print("UUUAAAAHHHHHHh")
					queue_free()
						
			if (time+begin_at) >= noteloop[cur_note] and cur_note != noteloop.size()-1:
				spawn_note()
				
			if (time) >= noteloop[curr_note_by_time] and curr_note_by_time != noteloop.size()-1:
				curr_note_by_time += 1
				getTimeBetweenNotes()
				Conductor.emit_signal("noteBeatSignal")
				
			if (time+0.1) >= noteloop[curr_noteSingleFrame] and curr_noteSingleFrame != noteloop.size()-1:
				var decimalPlaces = 2
				var multiplier = pow(10, decimalPlaces)

				curr_noteSingleFrame += 1
				var lastNoteTime = noteloop[curr_noteSingleFrame] - noteloop[curr_noteSingleFrame-1]
				var currentNoteTime = noteloop[curr_noteSingleFrame] - noteloop[curr_noteSingleFrame-1]
				Conductor.lastNoteTime = round(lastNoteTime * multiplier) / multiplier
				Conductor.currentNoteTime = round(currentNoteTime * multiplier) / multiplier
				
				if curr_note_by_time < noteloop.size()-2:
					var nextNoteTime = noteloop[curr_noteSingleFrame] - noteloop[curr_noteSingleFrame+1]
					Conductor.nextNoteTime = -round(nextNoteTime * multiplier) / multiplier

				getTimeBetweenNotes_SafeZone()
				Conductor.emit_signal("noteBeatSignalEarly")

			if !playing:
				time_fake += _delta
	else:
		visible = false
		$Strumbar.visible = false
		audioPlayer.volume_db -= (0.5 * 60) * _delta
		if (audioPlayer.volume_db <= -80):
			queue_free()

func initialSetup():
	_load()
	set_physics_process_internal(true)

	begin_at = note["notes"][str(show_in_advance)]
	time-=Conductor.crotchet*4

	for i in range(0,note["notes"].size()):
		noteloop.append(note["notes"][str(i)])
	number_of_notes = noteloop.size()

	Conductor.volume_db = -80

	destructTimer = Conductor.crotchet * 8


func _load():
	var file = FileAccess.open(song_chart, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var data = test_json_conv.get_data()
	note = data
	
func getTimeBetweenNotes():
	var currentTime = noteloop[curr_note_by_time]
	var deltaTime = currentTime - noteloop[curr_note_by_time-1]
	var expectedDeltaTime = Conductor.crotchet  # Replace this value with the expected time between consecutive notes at the song's BPM
	var tRatio = expectedDeltaTime / deltaTime
	timeBetween = tRatio
	Conductor.physicsSpeedMultiplier = timeBetween / (Conductor.crotchet * 1.85)

func getTimeBetweenNotes_SafeZone():
	var currentTime = noteloop[curr_noteSingleFrame]
	var deltaTime = currentTime - noteloop[curr_noteSingleFrame-1]

	var expectedDeltaTime = Conductor.crotchet
	var tRatio = expectedDeltaTime / deltaTime
	var timeBetweenS = tRatio
	
	var rounded = round(timeBetweenS / (Conductor.crotchet * 1.95) * 100) / 100
	GlobalDelta.lastDelta = 1 * Conductor.singleFramephysicsSpeedMultiplier
	Conductor.singleFramephysicsSpeedMultiplier = 1 * rounded
	
func spawn_note():
	if (CharaHandler.rhythmSystemEnable):
		var noteId = noteScene.instantiate()
		noteId.strumtime = noteloop[cur_note]
		noteId.advance = true
		noteId.note_id = cur_note

		if cur_note < number_of_notes-1:
			cur_note+=1
		call_deferred("add_child", noteId)

func disableChartDisplay():
	if visible:
		visible = false
		$Strumbar.visible = false
	else:
		visible = true
		$Strumbar.visible = true

func resetFunc():
	queue_free()
#
#func _exit_tree():
	#audioPlayer.queue_free()
	#queue_free()
