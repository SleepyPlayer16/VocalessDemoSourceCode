extends Node2D

@onready var dialogueScene = preload("res://Scenes/HUD/Dialogue_handler.tscn")
@onready var player = get_parent().get_node_or_null("PlayerObject")
@export var portrait = ""
@export var secondaryPortrait = ""
@export var character = ""
@export var dialoguePath = ""

var canBeTalkedTo = false
var talking = false
var dialogueCreated = false

func _ready():
	$AnimatedSprite2D.play("Idle")
	CutsceneHandler.dialogueEndedSignal.connect(stopTalk)
	Conductor.beatSignal.connect(idleSync)
	if CharaHandler.character != "Karu":
		visible = false

func _process(delta):
	if player != null and CharaHandler.character == "Karu":
		if player.position.x < position.x:
			scale.x = 1
		else:
			scale.x = -1
		if (Input.is_action_just_pressed("ui_up") and canBeTalkedTo):
			if (!talking and player.is_on_floor()):
				CutsceneHandler.npcCurrentlySpeaking = character
				talking = true
				player.playerSprite.scale.x = scale.x
		if (talking):
			if (!player.talking):
				$AnimatedSprite2D2.visible = false
				player.stateMachine.state = player.stateMachine.states.idle
				player.talking = talking
				player.playerSprite.speed_scale = 2
				player.playerSprite.play("Walk")
				player.velocity.x = 0
				
			player.position.x = move_toward(player.global_position.x, $Area2D.global_position.x - (24 * scale.x), 30 * delta)
			if player.position.x == $Area2D.global_position.x - (24 * scale.x):
				if !(dialogueCreated):
					dialogueCreated = true
					spawnDialogue(false)
					player.playerSprite.play("Idle")

func stopTalk():
	CutsceneHandler.npcCurrentlySpeaking = ""
	player.talking = false
	talking = false
	dialogueCreated = false
	$AnimatedSprite2D2.visible = true
	
func spawnDialogue(isCutscene):
	var dialogueInstance = dialogueScene.instantiate()
	dialogueInstance.dialogPath = dialoguePath
#
	#call_deferred("add_child", dialogueInstance)
	await get_tree().process_frame
	add_child(dialogueInstance)
	if (isCutscene):
		dialogueInstance.isCutsceneDialogue = true
	else:
		dialogueInstance.isNpcDialogue = true

func idleSync():
	$AnimatedSprite2D.play("Idle")
	if player != null:
		if player.talking and dialogueCreated:
			player.playerSprite.play("Idle")

func _on_area_2d_body_entered(body):
	if (body.name == "PlayerObject"):
		canBeTalkedTo = true


func _on_area_2d_body_exited(body):
	if (body.name == "PlayerObject"):
		canBeTalkedTo = false
