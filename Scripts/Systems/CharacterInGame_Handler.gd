extends Node

var character = null
var idealTime = 0.0
var idealParries = 0
var alt = 0
var loadChara = false
var goToTutorial = false
var level = 0

var characterData = {}
var characterPortrait = ""
var characterHudPortrait = ""
var playerHudJumpsNumbah = 0
var playerHudJumps = ""
var playerMaterial = ""
var phantomColor = ""

var effectsEnabled = true
var beatHitsEnabled = true
var rhythmSystemEnable = true
var debugControlsEnabled = false

var difficulty = difficulties.NORMAL

enum difficulties {
	NORMAL,
	HARD
}

func _ready():
	character = "Karu"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if character:
		loadChara = true
