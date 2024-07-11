extends StaticBody2D

var readyToBreak = false
var steps = 1
var timer = 0.5
var startTimer = false

@export var type = 0
@onready var song = preload("res://Music/mus_tutorialNEW.ogg")

@onready var focusBlock

func _ready():
	get_node("BreakableBlocks"+str(type)).visible = true
	focusBlock = get_node("BreakableBlocks"+str(type))
	Conductor.beatSignalBPM.connect(breakFunc)

func _process(delta):
	if (startTimer):
		timer -= delta
	if timer <= 0:
		queue_free()
		

func destroy():
	if steps == 1:
		$PreBreak.play()
		steps += 1
		focusBlock.frame = 1

func breakFunc():
	if steps == 2 and !startTimer:
		$Break.play()
		$CPUParticles2D.emitting = true
		$CollisionShape2D.set_deferred("disabled",true)
		focusBlock.visible = false
		startTimer = true
