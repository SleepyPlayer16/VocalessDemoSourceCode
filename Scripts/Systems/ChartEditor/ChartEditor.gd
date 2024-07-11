extends Node2D

@export var bpm = 60
@export var songToPlay = ""
var bps = 60/float(bpm)
var songPos = 0.0
var real_songPos = 0.0
var songPosition = 0.0
var notes = []
var lineSpeed = 5.0
var startTime: float = 0.0
var linePosition = 0
var zoom = 1
var speedFactor = 4

var snapValues = [4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 128, 192]
var currentSnapValue = 8

@onready var selector = $ColorRect
@onready var line = $Line
@onready var cam = $Line/Camera2D
@onready var song = $AudioStreamPlayer2D
@onready var note =  preload("res://Scenes/Note.tscn")
@onready var notesfx = $noteSound
@onready var speedFactorLabel = $CanvasLayer/RichTextLabel
@onready var snapValueLabel = $CanvasLayer/Snap
@onready var zoomValueLabel = $CanvasLayer/Zoom
@onready var songPositionLabel = $CanvasLayer/SongPosition

func _ready():
	cam.zoom *= zoom
	song.stream = load(songToPlay)
	bps = 60/float(bpm)
	speedFactorLabel.text = "Speed Factor: " + str(speedFactor)
	snapValueLabel.text = "Snap: " + str(snapValues[currentSnapValue])
	zoomValueLabel.text = "Zoom: x" + str(zoom)
	songPositionLabel.text = "Song Position: " + str(0.0)
	
func _process(delta):
	if zoom < 0.5:
		zoom = 0.5
	cam.zoom.x = zoom
	cam.zoom.y = zoom
	if real_songPos < 0:
		real_songPos = 0
		linePosition = 0
	if Input.is_action_just_pressed("ui_up"):
		speedFactor += 4
		speedFactorLabel.text = "Speed Factor: " + str(speedFactor)
	if Input.is_action_just_pressed("ui_down"):
		speedFactor -= 4
		speedFactorLabel.text = "Speed Factor: " + str(speedFactor)
		
	if Input.is_action_just_pressed("parry"):
		if !song.playing:
			song.play( line.position.x / 64 * bps  )
		else:
			real_songPos = song.get_playback_position()
			song.stop()
	
	if (song.playing):
		songPosition = song.get_playback_position() + AudioServer.get_time_since_last_mix()
		
		# Update the position of the line
		linePosition = songPosition / bps * 64
		real_songPos = songPosition
	songPositionLabel.text = "Song Position: " + str(float(str( real_songPos ).pad_decimals(3)))
	update_line_position()
	var mouse_position = get_global_mouse_position()

	selector.position.x = floor((get_global_mouse_position().x) / snapValues[currentSnapValue]) * snapValues[currentSnapValue]
	songPos = (selector.position.x / 64) * bps

func update_line_position():
	if (Input.is_action_pressed("ui_left")):
		real_songPos -= 0.001 * speedFactor
		linePosition = real_songPos / bps * 64
	elif (Input.is_action_pressed("ui_right")):
		real_songPos += 0.001 * speedFactor
		linePosition = real_songPos / bps * 64
		print(real_songPos)

	line.position.x = linePosition

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouseEvent = event as InputEventMouseButton
		if mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed:
			spawnNote()
			notes.append(songPos)
			notes.sort()
			print(notes)
			print(songPos)
		if mouseEvent.button_index == MOUSE_BUTTON_WHEEL_UP  and mouseEvent.pressed:
				if (currentSnapValue < snapValues.size()-1):
					currentSnapValue += 1
				snapValueLabel.text = "Snap: " + str(snapValues[currentSnapValue])
		elif mouseEvent.button_index == MOUSE_BUTTON_WHEEL_DOWN  and mouseEvent.pressed:
				if (currentSnapValue > 0):
					currentSnapValue -= 1
				snapValueLabel.text = "Snap: " + str(snapValues[currentSnapValue])

func spawnNote():
	var sceneInstance = note.instantiate()
	add_child(sceneInstance)
	sceneInstance.timeStamp = songPos
	sceneInstance.position = selector.position


func _on_line_col_area_entered(area):
	notesfx.play()
