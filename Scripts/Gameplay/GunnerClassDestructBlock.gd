extends StaticBody2D

var bulletDetected = false
var bullet
var timerBeforeDelete = 2
var gotHit = false
var disabled = false

@onready var col = $CollisionShape2D
@onready var col2 = $Area2D

@export var type = 0
@export var disappearingBlock = false

func _ready():
	$GunnerClassDestructBlock.frame = type
	#Change so it uses gunner class instead of character name, doing this just for the demo
	if (CharaHandler.character != "Applesauce" and disappearingBlock):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		$CollisionShape2D.set_deferred("disabled", true)
		disabled = true
		hide()
		set_process(false)

func _process(_delta):
	if gotHit:
		timerBeforeDelete -= _delta
	if timerBeforeDelete <= 0:
		queue_free()
	if bullet:
		bullet.get_parent().anticipation = 2
		if bullet.get_parent().queueForDeletion:
			#print("ayo what the fucjk")
			bullet.get_parent().sfx2.play()
			queue_free()

func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if (area.name == "BulletCol"):
		bulletDetected = true
		bullet = area
		
	if (area.name == "PunchHitbox" or area.name == "AirRollHitbox"):
		if !gotHit:
			area.get_parent().mayHitSfx.play()
			$WallDestroy.play()
			$GunnerClassDestructBlock.visible = false
			$CPUParticles2D.emitting = true
			$CollisionShape2D.set_deferred("disabled", true)
			gotHit = true


func _on_visible_on_screen_notifier_2d_screen_entered():
	if !(disabled and gotHit):
		$GunnerClassDestructBlock.show()
		col.set_deferred("disabled", false)
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	if !(disabled and gotHit):
		$GunnerClassDestructBlock.hide()
		col.set_deferred("disabled", false)
