extends Node

const SAVE_FILE = "user://user_data.cfg"
const CONTROL_FILE = "user://keybinds.cfg"
const CONTROL_FILE_PAD = "user://controllerMapping.cfg"
var default_data = {}
var keybind_data = {}
var controllerMap_data = {}
var story_data = {}
var actions = ["dash", "jump", "stomp", "customAction", "parry", "right", "left", "up", "down"]
var actionsPad = [
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

var original_data = ["musicVolume", "sfxVolume", "fullscreen","vsync", "cameraSmoothing", "windowSize", "fps"]
var windoSize
var maximized = false

func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	load_data()
	load_keybinds()
	#load_controllerMap()
	verifySettingsMidGameDeletion()
	verifySettingsMidGameDeletion()#dont judge me this shit dont work unless i execute it twice and i'm too lazy to figure out why 
	verifyMidGameDeletion()
	verifyMidGameDeletion()#same with this one
	#verifyBtnMidGameDeletion()
	#verifyBtnMidGameDeletion()#sorry
	if !default_data.is_empty():
		windoSize = default_data["windowSize"]
		if (default_data["fullscreen"] == true):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_size(Vector2i(480*default_data["windowSize"],270*default_data["windowSize"]))
			DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - DisplayServer.window_get_size() / 2)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if (default_data["vsync"] == true):
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		AudioServer.set_bus_volume_db(1, default_data["musicVolume"])
		AudioServer.set_bus_volume_db(2, default_data["sfxVolume"])
		Engine.max_fps = default_data["fps"]
	else:
		pass
	if !keybind_data.is_empty():
		resetKeybindData(false)
		resetKeybindData(false)

func load_data():
	var configSettings = ConfigFile.new()
#	var file: FileAccess = FileAccess.open(SAVE_FILE,FileAccess.READ)
	#general settings file
	if not FileAccess.file_exists(SAVE_FILE):
		configSettings.set_value("Settings", "musicVolume", 0)
		configSettings.set_value("Settings", "sfxVolume", 0)
		configSettings.set_value("Settings", "fullscreen", false)
		configSettings.set_value("Settings", "vsync", true)
		configSettings.set_value("Settings", "cameraSmoothing", true)
		configSettings.set_value("Settings", "windowSize", 2)
		configSettings.set_value("Settings", "fps", 120)
		configSettings.save(SAVE_FILE)
		var sections = configSettings.get_sections()
		for section in sections:
			var keys = configSettings.get_section_keys(section)
			for key in keys:
				var value = configSettings.get_value(section, key)
				default_data[key] = value
	else:
		var err = configSettings.load(SAVE_FILE)
		if (err != OK):
			printerr("Failed to load: ", err)
		else:
			var sections = configSettings.get_sections()
			for section in sections:
				var keys = configSettings.get_section_keys(section)
				for key in keys:
					var value = configSettings.get_value(section, key)
					default_data[key] = value

func load_controllerMap():
	var configSettings = ConfigFile.new()

	if not FileAccess.file_exists(CONTROL_FILE_PAD):
		for i in actionsPad:
			var event = InputMap.action_get_events(i)[0]
			print(event)
			if "button_index" in event:
				configSettings.set_value("ControllerMappings", i, [event["button_index"], event["pressure"], "button"])
				#configSettings.set_value("ControllerMappings", i, event)
				configSettings.save(CONTROL_FILE_PAD)
				var sections = configSettings.get_sections()
				for section in sections:
					var keys = configSettings.get_section_keys(section)
					for key in keys:
						var value = configSettings.get_value(section, key)
						controllerMap_data[key] = value
			elif "axis" in event:
				configSettings.set_value("ControllerMappings", i, [event["axis"], event["axis_value"], "axis"])
				#configSettings.set_value("ControllerMappings", i, event)
				configSettings.save(CONTROL_FILE_PAD)
				var sections = configSettings.get_sections()
				for section in sections:
					var keys = configSettings.get_section_keys(section)
					for key in keys:
						var value = configSettings.get_value(section, key)
						controllerMap_data[key] = value
	else:
		var err = configSettings.load(CONTROL_FILE_PAD)
		if (err != OK):
			printerr("Failed to load: ", err)
		else:
			var sections = configSettings.get_sections()
			for section in sections:
				var keys = configSettings.get_section_keys(section)
				for key in keys:
					var value = configSettings.get_value(section, key)
					controllerMap_data[key] = value

func load_keybinds():
	var configSettings = ConfigFile.new()
#	var file: FileAccess = FileAccess.open(CONTROL_FILE,FileAccess.READ)
	#general settings file
	if not FileAccess.file_exists(CONTROL_FILE):
		for i in actions:
			var event = InputMap.action_get_events(i)[0]
			var keyCode = OS.get_keycode_string(event.get_physical_keycode())
			configSettings.set_value("Keybinds", i, keyCode)
		configSettings.save(CONTROL_FILE)
		var sections = configSettings.get_sections()
		for section in sections:
			var keys = configSettings.get_section_keys(section)
			for key in keys:
				var value = configSettings.get_value(section, key)
				keybind_data[key] = value
	else:
		var err = configSettings.load(CONTROL_FILE)
		if (err != OK):
			printerr("Failed to load: ", err)
		else:
			var sections = configSettings.get_sections()
			for section in sections:
				var keys = configSettings.get_section_keys(section)
				for key in keys:
					var value = configSettings.get_value(section, key)
					keybind_data[key] = value

func save_settings(mus, sfx, full, vsync, smooth, winSize, fpss): 
	var configSettings = ConfigFile.new()
#	var file: FileAccess = FileAccess.open(SAVE_FILE,FileAccess.READ)
	configSettings.set_value("Settings", "musicVolume", mus)
	configSettings.set_value("Settings", "sfxVolume", sfx)
	configSettings.set_value("Settings", "fullscreen", full)
	configSettings.set_value("Settings", "vsync", vsync)
	configSettings.set_value("Settings", "cameraSmoothing", smooth)
	configSettings.set_value("Settings", "windowSize", winSize)
	configSettings.set_value("Settings", "fps", fpss)
	configSettings.save(SAVE_FILE)
	var sections = configSettings.get_sections()
	for section in sections:
		var keys = configSettings.get_section_keys(section)
		for key in keys:
			var value = configSettings.get_value(section, key)
			default_data[key] = value

func resetKeybindData(reset):
	if reset:
		if !keybind_data.is_empty():
			for i in range(actions.size()):
				InputMap.action_erase_events(actions[i])
				var key = OS.find_keycode_from_string(keybind_data[actions[i]])
				var event = InputEventKey.new()
				event.keycode = key
				InputMap.action_add_event(actions[i], event)
	else:
		verifyMidGameDeletion()
		var configSettings = ConfigFile.new()
#		var file: FileAccess = FileAccess.open(CONTROL_FILE,FileAccess.READ)
		#general settings file
		if not FileAccess.file_exists(CONTROL_FILE):
			for i in actions:
				var event = InputMap.action_get_events(i)[0]
				var keyCode = OS.get_keycode_string(event.get_physical_keycode())

				configSettings.set_value("Keybinds", i, keyCode)
			configSettings.save(CONTROL_FILE)
			var sections = configSettings.get_sections()
			for section in sections:
				var keys = configSettings.get_section_keys(section)
				for key in keys:
					var value = configSettings.get_value(section, key)
					keybind_data[key] = value
#DO LATER
func resetControllerMapData(reset):
	if reset:
		if !controllerMap_data.is_empty():
			for i in range(actionsPad.size()):
				InputMap.action_erase_events(actionsPad[i])
				var key = OS.find_keycode_from_string(controllerMap_data[actions[i]])
				var event = InputEventKey.new()
				event.keycode = key
				InputMap.action_add_event(actions[i], event)
	else:
		verifyMidGameDeletion()
		var configSettings = ConfigFile.new()
#		var file: FileAccess = FileAccess.open(CONTROL_FILE,FileAccess.READ)
		#general settings file
		if not FileAccess.file_exists(CONTROL_FILE_PAD):
			for i in actions:
				var event = InputMap.action_get_events(i)[0]
				var keyCode = OS.get_keycode_string(event.get_physical_keycode())

				configSettings.set_value("Keybinds", i, keyCode)
			configSettings.save(CONTROL_FILE_PAD)
			var sections = configSettings.get_sections()
			for section in sections:
				var keys = configSettings.get_section_keys(section)
				for key in keys:
					var value = configSettings.get_value(section, key)
					controllerMap_data[key] = value

func verifyMidGameDeletion():
	var configSettings = ConfigFile.new()
	configSettings.load(CONTROL_FILE)
	if not configSettings.has_section("Keybinds"):
		for i in actions:
			var event = InputMap.action_get_events(i)[0]
			var keyCode = OS.get_keycode_string(event.get_physical_keycode())

			configSettings.set_value("Keybinds", i, keyCode)
		configSettings.save(CONTROL_FILE)
	else:
		var keys = configSettings.get_section_keys("Keybinds")
		var original_keys = actions
		for key in original_keys:
			if not keys.has(key):
				configSettings.set_value("Keybinds", key, "")
		configSettings.save(CONTROL_FILE)
		
		var sections = configSettings.get_sections()
		for section in sections:
			for key in keys:
				var value = configSettings.get_value(section, key)
				keybind_data[key] = value

func verifyBtnMidGameDeletion():
	var configSettings = ConfigFile.new()
	configSettings.load(CONTROL_FILE_PAD)
	if not configSettings.has_section("ControllerMappings"):
		for i in actionsPad:
			var event = InputMap.action_get_events(i)[0]
			if event is InputEventJoypadButton:
				var btnNumber = [event.button_index, event.pressure, "button"]
				configSettings.set_value("ControllerMappings", i, btnNumber)
			if event is InputEventJoypadMotion:
				var btnNumber = [event.axis, event.axis_value, "axis"]
				configSettings.set_value("ControllerMappings", i, btnNumber)
		configSettings.save(CONTROL_FILE_PAD)
	else:
		var btns = configSettings.get_section_keys("ControllerMappings")
		var original_keys = actionsPad
		for btn in original_keys:
			if not btns.has(btn):
				configSettings.set_value("ControllerMappings", btn, "")
		configSettings.save(CONTROL_FILE_PAD)
		
		var sections = configSettings.get_sections()
		for section in sections:
			for btn in btns:
				var value = configSettings.get_value(section, btn)
				controllerMap_data[btn] = value

func verifySettingsMidGameDeletion():
	var configSettings = ConfigFile.new()
	configSettings.load(SAVE_FILE)
	
	# Checks if da Settings section exists
	if not configSettings.has_section("Settings"):
		#oh fuck it doesnt, create it with default values irght now
		configSettings.set_value("Settings", "musicVolume", 0)
		configSettings.set_value("Settings", "sfxVolume", 0)
		configSettings.set_value("Settings", "fullscreen", false)
		configSettings.set_value("Settings", "vsync", true)
		configSettings.set_value("Settings", "cameraSmoothing", true)
		configSettings.set_value("Settings", "windowSize", 2)
		configSettings.set_value("Settings", "fps", 120)
		configSettings.save(SAVE_FILE)
	else:
		#fuck yea it exists, now scan missing values
		var keys = configSettings.get_section_keys("Settings")
		var original_keys = original_data
		for key in original_keys:
			if not keys.has(key):
				if !(key == "musicVolume" or key == "sfxVolume" or key == "windowSize" or key == "fps"):
					configSettings.set_value("Settings", key, false)
				else:
					if (key == "windowSize"):
						configSettings.set_value("Settings", key, 2)
					elif (key == "fps"):
						configSettings.set_value("Settings", key, 120)
					else:
						configSettings.set_value("Settings", key, 0)
		configSettings.save(SAVE_FILE)
	
	var sections = configSettings.get_sections()
	for section in sections:
		var keys2 = configSettings.get_section_keys(section)
		for key in keys2:
			var value = configSettings.get_value(section, key)
			default_data[key] = value


