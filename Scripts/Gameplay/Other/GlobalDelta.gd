extends Node2D

var globalSlowDown = 1.0
var globalDelta = 1.0
var lastDelta = 1
var globalSongTime = 0.0

func _process(delta):
	globalDelta = delta * globalSlowDown
	globalSlowDown = 1

