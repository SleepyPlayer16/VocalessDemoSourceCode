extends Node

const OPTIONS_POSITIONS = [102, 166, 230, 294, 358, 422, 486, 38, 102]
const SECTION_TWO_POSITIONS = [232.0, 0.0, -270.0]

@export var bindingType = ""

var keycode
var btnName
var active = false
var changingKey = false

var actions = ["dash", "jump", "stomp", "customAction", "parry", "right", "left", "up", "down"]
var controller_actions = [
	"dash_ctr", 
	"jump_ctr", 
	"stomp_ctr", 
	"custom_action_ctr", 
	"parry_ctr", 
	"right_ctr", 
	"left_ctr", 
	"up_ctr", 
	"down_ctr"
]
const frameMappings = {
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
var actionName = []
var actionNameControlla = []

var actionTimer = 1
var asignKey = false
var assignTimer = 1
var waitingForKeyBtn = false

var currentIndex = 1
var options = 9

var section = 0

@onready var pressAnyKey = $pressAKeyBack
@onready var pressAnyBtn = $InputRemapping_Pad/pressAKeyBack
@onready var background = get_parent().get_node("OptionsMenuBack")
@onready var keys = [
	$Section1/DashKey, 
	$Section1/JumpKey, 
	$Section1/StompKey, 
	$Section1/SpecialKey, 
	$Section1/ParryKey, 
	$Section1/MoveRightKey, 
	$Section1/MoveLeftKey, 
	$Section2/UpKey, 
	$Section2/DownKey
]
@onready var buttonSpr = [
	$InputRemapping_Pad/SectionG1/DashBtn, 
	$InputRemapping_Pad/SectionG1/JumpBtn, 
	$InputRemapping_Pad/SectionG1/StompBtn, 
	$InputRemapping_Pad/SectionG1/SpecialBtn, 
	$InputRemapping_Pad/SectionG1/ParryBtn, 
	$InputRemapping_Pad/SectionG1/RightStick, 
	$InputRemapping_Pad/SectionG1/LeftStick, 
	$InputRemapping_Pad/SectionG2/UpMoveStick, 
	$InputRemapping_Pad/SectionG2/DownMoveStick
]
@onready var sectionG1 = $InputRemapping_Pad/SectionG1
@onready var sectionG2 = $InputRemapping_Pad/SectionG2
@onready var section1 = $Section1
@onready var section2  = $Section2

func _ready():
	Conductor.inputChange.connect(menuChange)
	keyboardMapping()
	#buttonMainMap(true)

#prepare to read the most dogshit input remapping system in the history of game development and mankind
func _process(delta):
	
	if (currentIndex > 7):
		background.position.y = lerp(background.position.y, -512.0, (0.4*60)*delta)
		section1.position.y = lerp(section1.position.y, SECTION_TWO_POSITIONS[2], (0.4*60)*delta)
		section2.position.y = lerp(section2.position.y, SECTION_TWO_POSITIONS[1]-30, (0.4*60)*delta)
	else:
		background.position.y = lerp(background.position.y, 0.0, (0.4*60)*delta)
		section1.position.y = lerp(section1.position.y, SECTION_TWO_POSITIONS[1], (0.4*60)*delta)
		section2.position.y = lerp(section2.position.y, SECTION_TWO_POSITIONS[0], (0.4*60)*delta)
	sectionG1.position.y = section1.position.y
	sectionG2.position.y = section2.position.y
		
	if (changingKey):
		actionTimer -= (0.5*60)*delta
		if (!waitingForKeyBtn):
			if (Conductor.playingWith == "keyboard"):
				if !(pressAnyKey.visible):
					if pressAnyBtn.visible:
						pass
						#print("FUCK YOU")
					else:
						waitingForKeyBtn = true
						pressAnyKey.show()
			if (Conductor.playingWith == "gamepad"):
				if !(pressAnyBtn.visible):
					if pressAnyKey.visible:
						pass
					else:
						waitingForKeyBtn = true
						pressAnyBtn.show()
	else:
		actionTimer = 1
		pressAnyKey.hide()
		pressAnyBtn.hide()
	if (asignKey):
		assignTimer -= (0.4*60)*delta
		if assignTimer <= 0:
			asignKey = false
			assignTimer = 1
			changingKey = false

func menuChange():
	if !waitingForKeyBtn:
		if (Conductor.playingWith == "keyboard"):
			section1.show()
			section2.show()
			sectionG1.hide()
			sectionG2.hide()
		else:
			section1.hide()
			section2.hide()
			sectionG1.show()
			sectionG2.show()

func keyboardMapping():
	for i in actions:
		var key = OS.find_keycode_from_string(UserData_Handler.keybind_data[i])
		actionName.append(UserData_Handler.keybind_data[i])
		InputMap.action_erase_events(i)
		var event = InputEventKey.new()
		event.keycode = key
		InputMap.action_add_event(i, event)
	for i in range(actions.size()):
		keys[i].text = str(actionName[i])

func _input(event):
	if (pressAnyKey.visible):
		changeKey(event)
	if (pressAnyBtn.visible):
		changeBtn(event)
		
func changeKey(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if event is InputEventKey and just_pressed:
		if (changingKey and actionTimer <= 0):
			if (OS.get_keycode_string(event.get_physical_keycode()) == "Enter" or OS.get_keycode_string(event.get_physical_keycode()) == "Escape"):
				Conductor.menuGoBack.play()
			else:
				Conductor.menuSelectSfx.play()
				for i in range(keys.size()):
					if keys[i].text == OS.get_keycode_string(event.get_physical_keycode()): #look for repeated inputs
						if i != currentIndex-1:
							keys[i].text = ""
							Input.action_release(actions[i])
							InputMap.action_erase_events(actions[i])
							Input.action_release(actions[i])
							assignKey(event)
							saveKeybind(actions[i],"")
					else:
						assignKey(event)
#only god knows what this shit does
func changeBtn(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if event is InputEventJoypadButton and just_pressed:
		if (changingKey and actionTimer <= 0):
			if (event.button_index == 6):
				Conductor.menuGoBack.play()
			else:
				Conductor.menuSelectSfx.play()
				for i in range(buttonSpr.size()):
					if buttonSpr[i].frame == event.button_index:
						if i != currentIndex-1:
							buttonSpr[i].frame = 35
							Input.action_release(controller_actions[i])
							InputMap.action_erase_events(controller_actions[i])
							Input.action_release(controller_actions[i])
							assignBtn(event, "button", false)
							saveBtnbind(controller_actions[i],[-5, event.pressure, "button"])
					else:
						assignBtn(event, "button", true)


	if event is InputEventJoypadMotion and (event.axis_value == -1.0 or event.axis_value == 1.0):
		if (changingKey and actionTimer <= 0):
			Conductor.menuSelectSfx.play()
			for i in range(buttonSpr.size()):
				if buttonSpr[i].frame == frameMappings[event.axis][int(event.axis_value)]:
					if i != currentIndex-1:
						Input.action_release(controller_actions[i])
						InputMap.action_erase_events(controller_actions[i])
						Input.action_release(controller_actions[i])
						assignBtn(event, "axis", false)
						saveBtnbind(controller_actions[i],[-5, -5, "axis"])
				else:
					assignBtn(event, "axis", true)

func assignKey(evento):
	InputMap.action_erase_events(actions[currentIndex-1])
	InputMap.action_add_event(actions[currentIndex-1], evento)
	keys[currentIndex-1].text = OS.get_keycode_string(evento.get_physical_keycode())
	
	saveKeybind(actions[currentIndex-1], OS.get_keycode_string(evento.get_physical_keycode()))
	asignKey = true
	waitingForKeyBtn = false

func assignBtn(evento, type, _reAdd):
	InputMap.action_erase_events(controller_actions[currentIndex-1])
	InputMap.action_add_event(controller_actions[currentIndex-1], evento)
	#changeIconFaster()
	if (!asignKey):
		if (type == "button"):
			saveBtnbind(controller_actions[currentIndex-1],[evento.button_index, evento.pressure, "button"])
		if (type == "axis"):
			saveBtnbind(controller_actions[currentIndex-1],[evento.axis, evento.axis_value, "axis"])
		await get_tree().create_timer(0.1).timeout #if i dont do this shit just explodes idk why i fucking suck at coding
		buttonMainMap(false)
		asignKey = true
		waitingForKeyBtn = false

func saveKeybind(key, value):
	UserData_Handler.verifyMidGameDeletion()
	if not FileAccess.file_exists(UserData_Handler.CONTROL_FILE):
		UserData_Handler.load_keybinds()
		UserData_Handler.resetKeybindData(true)
		UserData_Handler.resetKeybindData(true)
		var configSettings = ConfigFile.new()
		var err = configSettings.load(UserData_Handler.CONTROL_FILE)
		if (err != OK):
			print("you stupid bitch there was an error")
		else:
			configSettings.set_value("Keybinds", key, value)
			configSettings.save(UserData_Handler.CONTROL_FILE)
	else:
		var configSettings = ConfigFile.new()
		var err = configSettings.load(UserData_Handler.CONTROL_FILE)
		if (err != OK):
			print("you stupid bitch there was an error")
		else:
			configSettings.set_value("Keybinds", key, value)
			configSettings.save(UserData_Handler.CONTROL_FILE)

func saveBtnbind(key, value):
	UserData_Handler.verifyBtnMidGameDeletion()
	if not FileAccess.file_exists(UserData_Handler.CONTROL_FILE_PAD):
		UserData_Handler.load_controllerMap()
		#i dont remember why i commented this but i probably shouldn't have
		#UserData_Handler.resetControllerMapData(true)
		#UserData_Handler.resetControllerMapData(true)
		var configSettings = ConfigFile.new()
		var err = configSettings.load(UserData_Handler.CONTROL_FILE_PAD)
		if (err != OK):
			print("you stupid bitch there was an error")
		else:
			configSettings.set_value("ControllerMappings", key, value)
			configSettings.save(UserData_Handler.CONTROL_FILE_PAD)
	else:
		var configSettings = ConfigFile.new()
		var err = configSettings.load(UserData_Handler.CONTROL_FILE_PAD)
		if (err != OK):
			print("you stupid bitch there was an error")
		else:
			configSettings.set_value("ControllerMappings", key, value)
			configSettings.save(UserData_Handler.CONTROL_FILE_PAD)

func buttonMainMap(firstLoad):
	if !firstLoad:
		if (actionNameControlla.size() != 0):
			actionNameControlla.clear()

	for i in controller_actions:
		if (UserData_Handler.controllerMap_data[i][2] == "axis"):
			var btnIndex = UserData_Handler.controllerMap_data[i][0]
			var btnPressure = UserData_Handler.controllerMap_data[i][1]

			actionNameControlla.append(UserData_Handler.controllerMap_data[i])

			InputMap.action_erase_events(i)
			var event = InputEventJoypadMotion.new()
			if btnIndex >= 0:
				event.axis = btnIndex
				event.axis_value = btnPressure
			if !(event.axis == 0 and event.axis_value == 0.00):
				InputMap.action_add_event(i, event)
			
		####################################################
		if (UserData_Handler.controllerMap_data[i][2] == "button"):
			var btnIndex = UserData_Handler.controllerMap_data[i][0]
			var btnPressure = UserData_Handler.controllerMap_data[i][1]
			
			actionNameControlla.append(UserData_Handler.controllerMap_data[i])

			InputMap.action_erase_events(i)
			var event = InputEventJoypadButton.new()
			event.button_index = btnIndex
			event.pressure = btnPressure
			
			InputMap.action_add_event(i, event)

	for o in range(buttonSpr.size()):
		if (actionNameControlla[o][2] == "button"):
			if (actionNameControlla[o][0] < 0):
				buttonSpr[o].frame = 35
			else:
				buttonSpr[o].frame = actionNameControlla[o][0]
	for h in actionNameControlla:
		if h[2] == "axis":
			for e in range(actionNameControlla.size()):
				if actionNameControlla[e][2] == "axis":
					if (actionNameControlla[e][0] < 0):
						buttonSpr[e].frame = 35
					else:
						var axis = actionNameControlla[e][0]
						var direction = 1 if actionNameControlla[e][1] > 0 else -1
						buttonSpr[e].frame = frameMappings[axis][direction]
