extends Sprite2D

@onready var scr = get_parent()
#@onready var scr2 = get_parent().get_node_or_null("Strumbar/Control/spr_strumbar/AnimationPlayer")
@onready var player = get_tree().current_scene.get_node("PlayerObject")
var strumtime = 0.0
var advance = false
var note_id = 0
var layer = -1
var can_be_hit = true
var on_hold = false
var scroll_speed = 100
var safezone = 0.1
var hit_at = 0.0
var last_hit_index = null
var next_note = 0
var movetoleft = true
var closeness = 0
var originalPosition = position
var noteDone = false
var safeCheck = false
var noteLost = false
var noteGotHit = false
var pressedAt = 0.0
var safeZoneValue = 0.0
var miniNote = false
var songTime = 0.0
var strumBarPos = 480
var disableNote = false
var deletionTime = 0.5

var inputs = [
	"jump", 
	"stomp", 
	"dash",
	"parry",
	"customAction",
]

#func _ready():
	#add_to_group("notes")
	#modulate.a = 1

func _process(delta):
	if (!disableNote):
		songTime = scr.time

	if ( songTime >= strumtime-safezone and songTime <= strumtime+safezone ):
		if (player != null):
			player.stateMachine.GoodToGo()
		else:
			print("player not found")
	else:
		if (noteLost or (note_id == 0 and !Conductor.playing)):
			if (player != null):
				player.stateMachine.youFool()
			else:
				print("player not found")
	safeZoneValue = numberBetween(songTime, strumtime-safezone, strumtime+safezone)
	if songTime <=strumtime:
		modulate.a = -((strumtime-1.8)-songTime)*2
	elif songTime >=strumtime:
		modulate.a -= delta * 2
		if !noteLost:
			noteLost = true
			if !miniNote:
				Conductor.currentNote += 1

	if advance == true:
		match(movetoleft):
			true:
				position.x = strumBarPos + (strumtime-songTime)*scroll_speed
			false:
				position.x = strumBarPos - (strumtime-songTime)*scroll_speed

	if (!on_hold):
		if modulate.a <= 0 and songTime >= strumtime:
			if (deletionTime <= 0):
				queue_free()
			else:
				deletionTime -= delta
	else:
		modulate.a = 1
		advance = false
		position.x = strumBarPos
		if !$AnimationPlayer.is_playing():
			if (deletionTime <= 0):
				queue_free()
			else:
				deletionTime -= delta

func _input(event):
	if (event is InputEventKey and CutsceneHandler.npcCurrentlySpeaking == ""):
		for action in inputs:
			if (safeZoneValue and (Input.is_action_just_pressed(action) and !on_hold) and !noteDone):
				noteDone = true
				hit_at = songTime
				can_be_hit = false
				on_hold = true
				player.strumBar.seek(0.0,true)
				player.strumBar.play("Hit")
				$AnimationPlayer.play("Hit")
				break

func numberBetween(num, num1, num2):
	return num >= num1 and num <= num2
