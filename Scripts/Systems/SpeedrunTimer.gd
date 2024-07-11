extends CanvasLayer

var time_elapsed = 0
var loading = false
var enabled = true
var active = false
var tips = [
	"Press TAB to start or\npause/unpause timer \n",
	"Press SHIFT + CTRL \nto reset timer \n",
]
var tipChange = 2
var curTip = 0
var screenshotIndex = 0
var shiftTimer = 3
## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass
#
#
#func _process(delta):
	 ##Check if the user wants to take a screenshot (e.g., pressing a button)
	#if Input.is_action_just_pressed("screenshot"):
		#take_screenshot()	
	#if enabled:
		#if !(loading or get_tree().paused):
			#if (Input.is_action_just_pressed("speedrunTimerStop")):
				#time_elapsed = 0
			#if active:
				#time_elapsed += delta
				#$TimerText.text = _format_seconds(time_elapsed, true)
				#if $TimerText.position.y != 496:
					#$TimerText.position.y = 496
			#else:
				#tipChange -= delta
				#if tipChange <= 0:
					#tipChange = 2
					#curTip += 1
				#if curTip == 2:
					#curTip = 0
				#if $TimerText.position.y != 448:
					#$TimerText.position.y = 448
				#$TimerText.text = tips[curTip] + _format_seconds(time_elapsed, true)
			#if (Input.is_action_just_pressed("speedrunTimerStart")):
				#if !active:
					#active = true
				#else:
					#active = false
		#else:
			#$TimerText.text = "Just a sec..."
	#else:
		#hide()
#func _format_seconds(time : float, use_milliseconds : bool) -> String:
	#var minutes := time / 60
	#var seconds := fmod(time, 60)
	#if not use_milliseconds:
		#return "%02d:%02d" % [minutes, seconds]
	#var milliseconds := fmod(time, 1) * 100
	#return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
#
#func take_screenshot():
	#if enabled:
		#var screenshot = get_viewport().get_texture().get_image()
		#var unix_time: float = Time.get_unix_time_from_system()
		#var unix_time_int: float = unix_time #change back to int
		#var dt: Dictionary = Time.get_datetime_dict_from_unix_time(float(unix_time))
		#var ms: float = (unix_time - unix_time_int) * 1000.0 #change back to INT
		#screenshot.save_png("user://screenshot"+ str(dt.second) + str(ms) +".png")
