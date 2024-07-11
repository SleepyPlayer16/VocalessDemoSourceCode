extends Sprite2D

@onready var scr = get_parent()
@onready var scr2 = get_parent().get_node_or_null("Strumbar/Control/spr_strumbar/AnimationPlayer")
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
var noteLost = false
var noteGotHit = false
var pressedAt = 0.0
var safeZoneValue = 0.0
var miniNote = false
var songTime = 0.0
var strumBarPos = 480
var angle = 0

var inputs = [
	"jump", 
	"stomp", 
	"dash",
	"parry",
	"parry_ctr",
	"customAction",
	"jump_ctr", 
	"stomp_ctr", 
	"dash_ctr",
	"custom_action_ctr"
]

func _ready() -> void:
	add_to_group("notes")
	modulate.a = 1

func _process(delta: float) -> void:
	if !miniNote:
		songTime = scr.time
	else:
		songTime = GlobalDelta.globalSongTime
	for action in inputs:
		if ( songTime >= strumtime-safezone and songTime <= strumtime+safezone ):
			Conductor.emit_signal("just_Signal")
		else:
			if noteLost:
				Conductor.emit_signal("miss_Signal")
		if safeZoneValue:
			if (Input.is_action_just_pressed(action) and !on_hold) and !noteDone and CutsceneHandler.npcCurrentlySpeaking == "":
#				print("grrahh")
				if !on_hold:
					noteDone = true
					hit_at = songTime
					can_be_hit = false
					on_hold = true
				scr2.seek(0.0,true)
				scr2.play("Hit")
				$AnimationPlayer.play("Hit")

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
		rotacion(240,135,30*2,0.5,90,180)
		#match(movetoleft):
			#true:
				#position.x = strumBarPos + (strumtime-songTime)*scroll_speed
			#false:
				#position.x = strumBarPos - (strumtime-songTime)*scroll_speed

	if (!on_hold):
		if modulate.a <= 0 and songTime >=strumtime:
			queue_free()

	if on_hold:
		modulate.a = 1
		advance = false
		position.x = strumBarPos
		if !$AnimationPlayer.is_playing():
			queue_free()

func numberBetween(num, num1, num2):
	return num >= num1 and num <= num2
	
func rotacion(_pivot_x,_pivot_y,_radio,_velocidad,_start_degree,_end_degree):
	#//pivotX pivotY: coordenadas de el punto al cual estara rotando
	#//radio: pixeles del pivot al objeto que rota
	#//velocidad: frames para que haga una rotacion completa (60 es 1 segundo por defecto)
	#//_start_degree: angulo de spawn o donde se resetea
	#//_end_degree: angulo donde hace reset o borrado

	if angle >= get_radian_angle(_end_degree) or angle == 0:
		modulate.a -= 0.02
	var _delta = get_process_delta_time()
	angle += _delta*(_end_degree*(PI/_start_degree)) * scroll_speed
	position.x = strumBarPos + (strumtime-songTime) + (cos(angle)* _radio)
	position.y = strumBarPos + (strumtime-songTime) - (sin(angle)* _radio)
	#print(get_radian_angle(_end_degree))
#

func get_radian_angle(_degree):
	return (_degree*(PI/180))
