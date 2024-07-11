extends AnimatedSprite2D

var hasMatBeenSet = false
var posx = null
var posy = null
var wasOnGround = false
var amplitude = 2
var frequency = 10
var speed = 2.0
var initialY 
var disabledTimer = 6
var timeToDisappear = 3

@onready var parent
@onready var ray = $RayCast2D

func _ready():
	Conductor.beatSignal.connect(playIdle)
	var player_sprite_frames = parent.get_node("Smoothing2D/"+parent.currentCharacter).sprite_frames
	var afterimage_sprite_frames = player_sprite_frames.duplicate()
	sprite_frames = afterimage_sprite_frames
	var color = get_random_phantom_color()
	self.modulate = color
	modulate.a = 0
	speed_scale = 3
	if (wasOnGround):
		play("Idle")
	else:
		play("Fall")

func _physics_process(_delta):
	timeToDisappear -= _delta
	if timeToDisappear <= 0:
		get_parent().phantomDashOnCoolDown = false
		modulate.a -= (0.08 * 60) * _delta
		if modulate.a <= 0:
			queue_free()
	else:
		if !$PhantomParryArea/CollisionShape2D.disabled:
			disabledTimer -= 60 * _delta
		if disabledTimer <= 0:
			$PhantomParryArea/CollisionShape2D.set_deferred("disabled", true)
			disabledTimer = 6
		
		if modulate.a < 1:
			modulate.a += (0.03 * 60) * _delta
		else:
			modulate.a = 1
			
		if Input.is_action_just_pressed("parry"):
			speed_scale = 2.5
			$PhantomParryArea/CollisionShape2D.set_deferred("disabled", false)
			play("Parry")

		position.x = posx
		if !wasOnGround:
			position.y = posy + sin(Time.get_ticks_msec() / 1000.0 * 20) * 1.5
			$CPUParticles2D.position.y = posy
		else:
			position.y = posy
			$CPUParticles2D.position.y = posy
		$CPUParticles2D.position.x = posx
			
		if !(hasMatBeenSet and parent.playerSprite == null):
			hasMatBeenSet = false

			var parentMaterial = CharaHandler.phantomColor
			get_material().set("shader_parameter/palette", parentMaterial)
			ray.enabled = true

			#modulate.a -= (0.035*60)*delta
		#else:
			#queue_free()

func playIdle():
	if get_animation() != "Parry":
		speed_scale = 2
		if wasOnGround:
			play("Idle")
		else:
			play("Fall")


func get_random_phantom_color():
	var colors = [
		Color(0.5, 0.8, 1),      # Light blue
	]
	return colors[randi() % colors.size()]

func _exit_tree():
	stop()
	var frm = get_sprite_frames()
	frm.clear_all()
	queue_free()


func _on_animation_finished():
	if get_animation() == "Parry" and frame > 2:
		speed_scale = 2
		if (wasOnGround):
			play("Idle")
		else:
			play("Fall")
