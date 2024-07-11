extends Node2D

@export var action = []
@export var type = 0
@export var txt = ""
@export var additionalTxt = ""
var actionCtr = []
var keybind_data = UserData_Handler.keybind_data
var controller_data = UserData_Handler.controllerMap_data
var actionName = []
var controllerActionName = []
var playerEntered = false
var playerObject
var btnImg = ""
var btnImgSec = ""
@onready var txtLabel = $CanvasLayer/ColorRect/RichTextLabel
const FRAMEMAPPINGS = {
	0: { -1: 20, 1: 21 },
	1: { -1: 22, 1: 23 },
	2: { -1: 24, 1: 25 },
	3: { -1: 26, 1: 27 },
	4: { -1: 28, 1: 29 },
	5: { -1: 30, 1: 31 },
	6: { -1: 28, 1: 32 },
	7: { -1: 30, 1: 33 },
	8: { -1: 28, 1: 32 },
	9: { -1: 30, 1: 33 },
}
func _ready():
	Conductor.destroyNotes.connect(resetFunc)
	Conductor.inputChange.connect(enText)
	if (action.size() != 0):
		for i in action:
			actionName.append(keybind_data[i])
			#if ( i == "customAction"):
				#actionCtr.append("custom_action_ctr")
			#else:
				#actionCtr.append(i+"_ctr")
		#for i in actionCtr:
			#controllerActionName.append(controller_data[i])
	enText()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playerEntered:
		$CanvasLayer/ColorRect.modulate.a = clamp($CanvasLayer/ColorRect.modulate.a + ((0.09*60)*delta), 0, 1)
	else:
		$CanvasLayer/ColorRect.modulate.a = clamp($CanvasLayer/ColorRect.modulate.a - ((0.09*60)*delta), 0, 1)

func _on_area_2d_body_entered(body):
	if (body.name == "PlayerObject"):
		body.reading = true
		playerEntered = true
		playerObject = body

func _on_area_2d_body_exited(body):
	if (body.name == "PlayerObject"):
		playerEntered = false
		body.reading = false

func enText():
	#i might be stupid
	if (action.size() != 0):
		if (actionName.size() > 1):
			if (Conductor.playingWith == "keyboard"):
				$CanvasLayer/ColorRect/RichTextLabel.text = txt + "[color=yellow]("+actionName[0]+")[/color]" + " and " + "[color=yellow]("+actionName[1]+")[/color]" + additionalTxt
			else:
				buttonDetector(true)
				$CanvasLayer/ColorRect/RichTextLabel.text = txt + "[img]"+btnImg+"[/img]" + " and " + "[img]"+btnImgSec+"[/img]" + additionalTxt
		elif (actionName.size() == 1):
			if (Conductor.playingWith == "keyboard"):
				$CanvasLayer/ColorRect/RichTextLabel.text = txt + "[color=yellow](" + actionName[0] + ")[/color]" + additionalTxt
			else:
				buttonDetector(false)
				$CanvasLayer/ColorRect/RichTextLabel.text = txt + " [img]"+btnImg+"[/img] " + additionalTxt
	else:
		$CanvasLayer/ColorRect/RichTextLabel.text = txt

func buttonDetector(hasMoreThanOneBtn):
	if (controllerActionName[0][2] == "button"):
		if (controllerActionName[0][0]) == -5:
			btnImg = "res://Sprites/Buttons/"+str(35)+".png"
		else:
			btnImg = "res://Sprites/Buttons/"+str(controllerActionName[0][0])+".png"
	else:
		var axis = controllerActionName[0][0]
		var direction = 1 if controllerActionName[0][1] > 0 else -1
		if (axis == -5):
			btnImg = "res://Sprites/Buttons/"+str(35)+".png"
		else:
			btnImg = "res://Sprites/Buttons/"+str(FRAMEMAPPINGS[axis][direction])+".png"
	if (hasMoreThanOneBtn):
		if (controllerActionName[1][2] == "button"):
			if (controllerActionName[1][0] == -5):
				btnImgSec = "res://Sprites/Buttons/"+str(35)+".png"
			else:
				btnImgSec = "res://Sprites/Buttons/"+str(controllerActionName[1][0])+".png"
		else:
			var axis = controllerActionName[1][0]
			var direction = 1 if controllerActionName[1][1] > 0 else -1
			if (axis == -5):
				btnImgSec = "res://Sprites/Buttons/"+str(35)+".png"
			else:
				btnImgSec = "res://Sprites/Buttons/"+str(FRAMEMAPPINGS[axis][direction])+".png"

func resetFunc():
	$CanvasLayer.visible = false
