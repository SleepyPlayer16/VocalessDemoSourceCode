extends RichTextLabel

var textToShow = ""
var timer = 1
var good = true
# Called when the node enters the scene tree for the first time.
func _ready():
	#print("COME ON MAN")
	if good:
		text = "[center][wave amp=50.0 freq=5.0 connected=1][color=#4dfa41]" + textToShow + "[/color][/wave][/center]"
	else:
		text = "[center][color=#dc1d3c]" + textToShow + "[/color][/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	position.y += 30 * delta
	if timer <= 0:
		modulate.a -= (0.05 * 60) * delta
		if modulate.a <= 0:
			queue_free()
