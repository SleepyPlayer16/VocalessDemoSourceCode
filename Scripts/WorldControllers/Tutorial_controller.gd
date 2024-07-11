extends Node2D

@onready var mayTutScreen = $MayTutorialScreen
@onready var dashTutScreen = $DashTutScreen
@onready var stompTutScreen = $MayTutScreen3

func _ready():
	if (CharaHandler.character != "May"):
		dashTutScreen.txtLabel.text = dashTutScreen.txt + "[color=yellow](" + dashTutScreen.actionName[0] + ")[/color]" + dashTutScreen.additionalTxt + " Try dashing to the next platform to the beat!"
		mayTutScreen.hide()
		$SKELETILES.call_deferred("queue_free")
		mayTutScreen.set_process(false)
	else:
		$SKELETILES.show()
		$ParallaxBackground3.show()
		$ParallaxBackground2.hide()
		$songAuthorCard2.show()
		$songAuthorCard.hide()
		$GroundTiles.call_deferred("queue_free")
	stompTutScreen.txtLabel.text = "You can stomp diagonally with May by pressing " + "[color=yellow](" + stompTutScreen.actionName[0] + ")[/color] + " + "[color=yellow](" + stompTutScreen.actionName[1] + " or " + stompTutScreen.actionName[2] + ")[/color]" + " when using your stomp move!"
