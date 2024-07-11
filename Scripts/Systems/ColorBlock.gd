extends Node

var beat = 1
var actualbeat = 1
var event = 1
var timer = 60
var cycle = 0
var process_code = true

var time_begin
var time_delay

@export var blockType = 0
@onready var sfx = $AudioStreamPlayer
@onready var collision = $StaticBody2D/CollisionShape2D
@onready var sprite = $SprGreenBlock

@onready var textureGreen = preload("res://Sprites/StageObjects/spr_greenBlock.png")
@onready var texturePurple = preload("res://Sprites/StageObjects/spr_purpleBlock.png")
@onready var textureRed = preload("res://Sprites/StageObjects/spr_pinkBlock.png")
@onready var texturYellow = preload("res://Sprites/StageObjects/spr_yellowBlock.png")


# Called when the node enters the scene tree for the first time.
func _ready():
#	Conductor.noteBeatSignalEarly.connect(FUCKAAAAAAAA)
	match(blockType):
		0:
			sprite.texture = textureGreen
		1:
			sprite.texture = texturePurple
		2:
			sprite.texture = textureRed
		3:
			sprite.texture = texturYellow

func _process(_delta):	
	beat = Conductor.beatCounter
	match(blockType):
		0:
			handleBlockTypeBeat(4, 8)
		1:
			handleBlockTypeBeat(3, 7)
		2:
			handleBlockTypeBeat(2, 6)
		3:
			handleBlockTypeBeat(1, 5)

func FUCKAAAAAAAA():
	beat += 1
	if beat > 8:
		beat = 1

func handleBlockTypeBeat(beatNum, beatNumTwo):
	if beat == beatNum and cycle == 0:
		sfx.play()
		cycle = 1
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		#collision.disabled = true
		sprite.frame = 1

	if beat == beatNumTwo and cycle == 1:
		sfx.play()
		cycle = 0
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
		sprite.frame = 0	
