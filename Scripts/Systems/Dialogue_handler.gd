extends Control

@export var dialogPath = ""
@export var textSpeed = 0.025
var dialog
var phraseNum = 0
var finished = false
var thread: Thread

@onready var charaName = $CanvasLayer/TextBox/Name
@onready var charaText = $CanvasLayer/TextBox/Text
@onready var timer = $CanvasLayer/Timer
@onready var portraitLeft = $CanvasLayer/A
@onready var portraitRight = $CanvasLayer/B
@onready var portraitRightSecond = $CanvasLayer/B/C
@onready var animPlayer = $AnimationPlayer
@onready var dialogueDone = false
@onready var deletionTimer = 0.2
@onready var isNpcDialogue = false
@onready var isCutsceneDialogue = false

func _ready():
	Conductor.destroyNotes.connect(resetFunc)
	timer.wait_time = textSpeed
	dialog = getDialog()
	#assert(dialog, "No se encontró ningún dialogo, avisarme si te ocurre en una sección importante del juego")
	nextPhrase()

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		if finished:
			nextPhrase()
		else:
			charaText.visible_characters = len(charaText.text)
	if (dialogueDone):
		deletionTimer -= delta
		if (deletionTimer <= 0):
			if (isNpcDialogue):
				CutsceneHandler.emit_signal("dialogueEndedSignal")
			elif (isCutsceneDialogue):
				CutsceneHandler.emit_signal("cutsceneDialogueEndedSignal", 1)
			queue_free()

func getDialog():
	var file = FileAccess.open(dialogPath, FileAccess.READ)
	var parsedResult = JSON.parse_string(file.get_as_text())
	
	if (parsedResult is Array):
		return parsedResult
	else:
		print("hijo de su perra mdre algo falló aaaaaaaaa")
		return {}

func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		animPlayer.speed_scale *= 2
		dialogueDone = true
		animPlayer.play_backwards("In")
		
		return

	finished = false
	if (phraseNum == 0):
		portraitLeft.texture = load("res://Sprites/Portraits/" + dialog[phraseNum]["CharacterLeft"] + "/Neutral.png")
		portraitRight.texture = load("res://Sprites/Portraits/" + dialog[phraseNum]["CharacterRight"] + "/Neutral.png")
		
		phraseNum += 1
	
	if (dialog[phraseNum]["SecondaryName"] != ""):
		charaName.text = dialog[phraseNum]["Name"] + " and " + dialog[phraseNum]["SecondaryName"]
	else:
		charaName.text = dialog[phraseNum]["Name"]
	charaText.text = dialog[phraseNum]["Text"]
	
	charaText.visible_characters = 0
	var img = "res://Sprites/Portraits/" + dialog[phraseNum]["Name"] + "/" + dialog[phraseNum]["Emotion"] + ".png"
	var portraitToChange = dialog[phraseNum]["Side"]
	
	if (portraitToChange == "Left"):
		portraitLeft.modulate.a = 1
		portraitLeft.texture = load(img)
		portraitRight.modulate.a = 0.5
	elif (portraitToChange == "Right"):
		portraitRight.modulate.a = 1
		portraitRight.texture = load(img)
		portraitRight.offset.x = int(dialog[phraseNum]["offset"])
		portraitLeft.modulate.a = 0.5
	elif (portraitToChange == "Right-second"):
		var offset = int(dialog[phraseNum]["SecondaryOffset"])
		var imgSecondary = "res://Sprites/Portraits/" + dialog[phraseNum]["SecondaryName"] + "/" + dialog[phraseNum]["Emotion"] + ".png"
		portraitRight.modulate.a = 1
		portraitRightSecond.modulate.a = 1
		portraitRightSecond.texture = load(imgSecondary)
		portraitRightSecond.offset.x -= offset
		portraitLeft.modulate.a = 0.5
	
	while charaText.visible_characters < len(charaText.text):
		charaText.visible_characters += 1
		$VoiceBeep.play()
		$VoiceBeep.pitch_scale = 1 + randf_range(-0.1,0.1)
		timer.start()
		await timer.timeout
	
	finished = true
	phraseNum += 1
	return

func resetFunc():
	$CanvasLayer.visible = false
