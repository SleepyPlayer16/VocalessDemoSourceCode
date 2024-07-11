extends Node2D

var sectionIntro = preload("res://Music/SECTION_TESTS/symph_intro.ogg")
var sectionOne = preload("res://Music/SECTION_TESTS/symph_section1.ogg")
var sectionTwoTransition = preload("res://Music/SECTION_TESTS/symph_section2Transition.ogg")
var sectionTwo = preload("res://Music/SECTION_TESTS/symph_section2.ogg")
var sectionThreeTransition = preload("res://Music/SECTION_TESTS/symph_section3Transition.ogg")
var sectionThree = preload("res://Music/SECTION_TESTS/symph_section3.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	Conductor.songSections.append(sectionIntro)
	Conductor.songSections.append(sectionOne)
	Conductor.songSections.append(sectionTwoTransition)
	Conductor.songSections.append(sectionTwo)
	Conductor.songSections.append(sectionThreeTransition)
	Conductor.songSections.append(sectionThree)
	Conductor.songToLoad(128, -1, load("res://Music/SECTION_TESTS/symph_intro.ogg"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("simulateGoToNextSection"):
		if (Conductor.fourthBeat == 4):
			Conductor.waitUp = true
		Conductor.goToNextSection = true
