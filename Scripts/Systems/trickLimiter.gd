extends Area2D

var shouldLimitPlayer = false
var playerIn = false
var tricks = 0
var trickLimit = 5

func _on_body_entered(body):
	if (body.name == "PlayerObject"):
		body.insideOfTrickLimitArea = true
		body.limitArea = self
		playerIn = true

func _on_body_exited(body):
	if (body.name == "PlayerObject"):
		body.limitArea = null
		playerIn = false
		body.insideOfTrickLimitArea = false
