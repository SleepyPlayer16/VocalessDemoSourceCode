extends Node2D

var deaths = 0
var firstDeath = 0
var parries = 0
var timeElapsed = 0.0
var parryScore = 550
var totalParries = CharaHandler.idealParries
var totalstagetime = CharaHandler.idealTime
var score = 0.0

@onready var ranking = $SprIngameRank
@onready var rankEffect = $SprRankEffect

func _ready():
	Conductor.beatSignalBPM.connect(beat)

func _process(delta):
	if (rankEffect.scale.x > 0.0):
		rankEffect.scale.x = lerp(rankEffect.scale.x, 2.0, (0.08 * 60) * delta)
		rankEffect.scale.y = rankEffect.scale.x
	if (ranking.scale.x > 0.0):
		ranking.scale.x = lerp(ranking.scale.x, 2.0, (0.08 * 60) * delta)
		ranking.scale.y = ranking.scale.x
	# Sound plays back continuously, so the graph needs to be updated every frame.
	#queue_redraw()
	var timePenaltyLoss = max((timeElapsed - CharaHandler.idealTime) * 35, 0)
	var deathPunishment = deaths*70
	var firstDeathPunishment = firstDeath * 650
	var parryCalculation = (parryScore*parries)

	var preCalcScore = (((10000-(parryScore*CharaHandler.idealParries)) + parryCalculation) - (firstDeathPunishment + deathPunishment)) - timePenaltyLoss
	if score >= 9500:
		ranking.frame = 0
	elif score < 9500 and score >= 9000:
		ranking.frame = 1
	elif score < 9000 and score >= 7800:
		ranking.frame = 2
	elif score < 7800 and score >= 6500:
		ranking.frame = 3
	elif score < 6500 and score >= 5000:
		ranking.frame = 4
	elif score < 6500:
		ranking.frame = 5
	if preCalcScore < 0:
		score = 0
	else:
		score = preCalcScore
		
func beat():
	rankEffect.scale.x = 2.5
	rankEffect.scale.y = 2.5
	ranking.scale.x = 2.2
	ranking.scale.y = 2.2
	rankEffect.frame = 0
	rankEffect.play("default")
