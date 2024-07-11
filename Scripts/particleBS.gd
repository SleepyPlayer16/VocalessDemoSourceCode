extends Node

var walkParticles = preload("res://Scenes/FX/dustParticles.tscn")
var powerPart = preload("res://Scenes/FX/powerParticles.tscn")
var steamPart = preload("res://Scenes/FX/steamPart.tscn")
var songItem = preload("res://Scenes/Menus/SongItem.tscn")

var materials = [walkParticles, powerPart, steamPart]
# Called when the node enters the scene tree for the first time.
func _ready():
	for material in materials:
		var particles_instance = material.instantiate()
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_emitting(true)
		self.call_deferred("add_child", particles_instance)
	var songItemObject = songItem.instantiate()
	songItemObject.set_modulate(Color(1,1,1,0))
	self.call_deferred("add_child", songItemObject)
