extends Node2D

var showKsStuff = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (showKsStuff):
		$SprKsLiveNow.modulate.a = lerp($SprKsLiveNow.modulate.a, 1.0, (0.06 * 60) * delta)
	if (Input.is_action_just_pressed("dash")):
		$AnimationPlayer.play("scroll")
	if (Input.is_action_just_pressed("jump")) and $Timer.is_stopped:
		$Timer.start()
		if ($AnimatedSprite2D.get_animation() == "default"):
			$AnimatedSprite2D.play("close")
			
		if ($AnimatedSprite2D.get_animation() == "close" and $AnimatedSprite2D.frame > 1):
			$AnimatedSprite2D.play("vanish")
			


func _on_animated_sprite_2d_animation_finished():
	if ($AnimatedSprite2D.get_animation() == "vanish" and $AnimatedSprite2D.frame > 1):
		showKsStuff = true
