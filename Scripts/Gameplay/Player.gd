class_name Player
extends CharacterBody2D

const SPEED = 10.0 # General speed stat used by every character
const TRIP_SPEED_MULTIPLIER = 300 # Trip horizontal speed

var reading = false # Checks if player is reading a tutorial screen
var camTimer = 0.5 # Disables camera smoothing for a few frames after entering a level
var checkedForCamSmoothing = false # Does a check for camera smoothing to no mess up player saved settings
var jumpsp = 0 # Player's final jump speed with all calculations
var falling = false # Checks if player is falling
var jumpFromSnowBall = false # Checks if player has jumped from a snowball after it has crashed on a wall
var canActivateDebug = false # Checks if player can activate debug mode
var canPhantomDash = false # Checks if player can phantom dash
var dashSpeed = 0
var phantomDashSpeed = 5 # Speed to add to default dash speed after using a phantom dash
var jumpBoostPawaaaa = 0 # Extra jump speed for when you are on an orange platform
var platformBoosted = false # Checks if player is in a boosted jump
var height = 40 # Player's jump velocity, how high the player jumps
var gravity = 500 
var maxWalkVelocity = 2 # Player's velocity when walking
var maxVelocity = 6 # Max walking velocity
var facing = 1 # Direction player is looking at
var phantomDashOnCoolDown = false # Checks if phantom dash is on cooldown
var phantomTime = 0 # How long the blue trail and afterimages last after using a phantom dash
var phantomTimeDecrease = 0.1 # How fast the phantom time timer decreases, adapts to song's beatmap.
var dashNumber = 1 # Current dash number
var dashMaxNumber = 3 # Max number of dashes allowed in the air
var diagDashNumber = 1 # Current Dash Number
var diagDashMaxNumber = 3 # Max number of diagonal dashes allowed (Starts at 1)
var dashSnapTimer = 0 # Timer used to avoid character from instantly snapping when starting a dash
var dashSnapTimerDecrease = 0.1 # How fast the snap timer decreases
var jumpNumber = 1 # Current jump number
var maxJumps = 3 # Max number of jumps allowed (Starts at 1)
var diagDashUp = false # Checks if the player has used an upwards diagonal dash
var diagDashDown = false # Checks if the player has used a downwards diagonal dash
var oldVelocity = 0 # Horizontal Velocity
var oldVelocityVertical = 0 # Vertical Velocity
var time_remaining = 15 # idk what this does
var has_usedDashDirChange = false # Checks if player has changed direction during a dash (Horizontal)
var has_usedVerticalDashDirChange = false # Checks if player has changed direction during a dash (Vertical)
var hitStopActive = false # Checks if player is on hitstop
var hitStopTimer = 0 # How many frames the player will be on hitstop, depends on enemy parried
var previousVelocityY = 0 # Saves previous horizontal velocity to re-apply it on certain situations (mainly hitstop)
var previousVelocityX = 0 # Saves previous vertical velocity to re-apply it on certain situations (mainly hitstop)
var hitStopDecreaseSpeed = 0 # How fast hitstop timer decreases
var tripNumber = 0 # Current trip number
var maxTrips = 2 # Max number of trips allowed
var tripTime = 25 # Probably does nothing but I'm not sure
var punishTrip = false # Checks if tripping should be punished by not allowing the player to move during one
var groundedTime = 30 # How many frames until the character gets up from being grounded after a trip
var debugMovementSpeed = 5 # Speed during debug mode
var currentCharacter = "Karu" # Current character you're playing as
var debugModeActive = false # Checks if debug mode is active so the player can disable the HUD and Collisions
var canWallJump = false # Checks if player can wall jump
var fallThroughRail = false # Prevents player from getting on a rail instantly after falling by pressing down
var hasWallJumped = false # Checks if player has wall jumped
var wallJumpTimer = 20 # If timer is greater than 0, player should not be able to move for a few frames, adapts to beatmap
var wallJumpTime = 20 # Same as before for some reason, if I remove this walljump stops working
var wallJumpTimerDecreaseRate = 75.0 # How fast the wall jump timer decreases
var deathTimer = 20 # How many frames the player last in the death state
var inputBeat = false # makes the combo text shake whenever u hit something to the beat
var wasGrindin = false # Checks if last state was the grind state to preserve momentum
var trickRotation = 1 # Used for rotating between trick sprites when grinding
var die = false # Checks if player is death to play death animation and reset variables
var win = false # Checks if player has touched level's goal
var exitingScene = false # Checks if player is exiting the scene to free/get rid of garbage
var inSnowBall = false # Checks if player is inside a snowball
var talking = false # Checks if player is currently talking to an NPC
var has_dashed = false # Checks if player is currently dashing
var deaths = 0 # Death number used for ranking system
var firstDeath = 0 # Checks if player has died for the first time, first death deducts way more points than all other deaths
var parries = 0 # Keeps track of how many enemies the player has parried
var totalParries = 3 #Does nothing I think
var timeElapsed = 0.0 #Time passed, used for ranking system
var physicsMultiplier = 0.1 #Does nothing I think
var comboScore = 0 #Does nothing I think
var running = false #running for Nay
var stompDropKick = false #Alt stomp state for May
var airRollAttack = false #Checks if may has attacked while in the air and while in the dash state
var runSpeed = 5.0
var actionBoost = 130.0
var currentActionBoost = 0.0
var currentPunchNumbah = 0 #Cycles between punch animations (May only)
var characterClass = "Dasher" #3 classes, Dasher, Gunner, Grappler
var insideOfTrickLimitArea = false
var limitArea = null
var storedCharge = false
var loading = true
var lastCheckpoint #Last position where the player will be teleported to after dying, used for checkpoints
#var points = [
	##[Vector2(0, 0), 0, Vector2(0, 0), 10],
	#[Vector2(-2, 3), 4, Vector2(0, 0), 8],
	#[Vector2(-1, 3), 3.5, Vector2(0, 0), 7],
	#[Vector2(-1, 2), 3, Vector2(0, 0), 6],
	#[Vector2(-1, 2), 2.5, Vector2(0, 0), 5],
	#[Vector2(0, 1), 2, Vector2(0, 0), 4],
#]

var isOnSlope = false # Checks if player is on a slope
var rankAppearTimer = 3.75 # How long until the rank shows up on screen after entering a level
var inCountdown = false # Checks if countdown is active
var countNumb = 0 # Current number of the countdown
var isInDashAnim = false # Checks if the current animation is dash animation
var last_animation = "Dash" # Checks what the last Dash animation was, used for air and grounded variants
var lmao = false # Checks if player messed up a boosted jump
var lmaoCounter = 2 # How many beats to count before the player dies to a messed up boosted jump

#Named nodes that are found within the player scene
#Animation player nodes
@onready var animPlayer = $AnimationPlayer
@onready var pauseMenuAnim = $PauseMenu/AnimationPlayer

#Sound Effects
@onready var metronome = $Metronome #Sound effect used when doing any action to the beat
@onready var jumpSfx = $Jump
@onready var boostedJumpSfx = $BoostedJump
@onready var dashSfx = $Dash
@onready var phantomDashSfx = $PhantomDash
@onready var powerChargeSfx = $ChargeActivate
@onready var phantomActivationSfx = $PhantomTimeActivate
@onready var tripSfx = $Trip
@onready var killSfx = $Death
@onready var parrySfx = $Parry
@onready var railSfx = $RailGrind
@onready var railHopOnSfx = $RailHopOn
@onready var swing1Sfx = $Swing1
@onready var swing2Sfx = $Swing2
@onready var mayHitSfx = $MayHit
@onready var spinSfx = $Spin

#STATEMACHINE, manages player current state, ex: falling, jumping, idle, walking
@onready var stateMachine = $StateMachine

#RayCasts
@onready var rayW = $RayCast2D
@onready var rayWTwo = $RayCast2D2
@onready var rayWThree = $RayCast2D3
@onready var bulletRay = $bulletRaycast #Used to know where a bullet will go, gunner class only
@onready var benboRay1 = $benboCastWallJump1
@onready var benboRay2 = $benboCastWallJump2
@onready var grindRay = $GrindRay

@onready var collision = $CollisionShape2D3
#FX
@onready var dashLine = $DashLine
@onready var dustParticles = $Dust
@onready var parryMarker = $ParryMarker
@onready var speedlines = $CanvasLayer/stuff/SprSpeedLines
@onready var boostedJunmpParticles = $BoostedJumpParticles
@onready var deathAnim = $DeathExplosion
@onready var afterImageTimer = $AfterImageTimer
@onready var phantomParticles = $PhantomParticles
@onready var parryFx = preload("res://Objects/FX/ParrySuccessFX.tscn")

#Other
@onready var speedLineTimer = $SpeedlineTimer
@onready var cam = $Smoothing2D/Camera2D
@onready var smoothing = $Smoothing2D
@onready var timePlusOrLessText = preload("res://Scenes/HUD/ScoreRichText.tscn") #Rich Text that shows up after parrying or getting a combo of 30
@onready var playerSprite = null

#HUD
@onready var playerHudPortrait = $CanvasLayer/stuff/SprHudPortrait
@onready var playerHudIcon = $CanvasLayer/stuff/SprDashIcons
@onready var playerHudJumps = $CanvasLayer/stuff/SprJumpIndicator
@onready var playerHudDash = $CanvasLayer/stuff/SprNormalDashIndicator
@onready var playerHudDiagDash = $CanvasLayer/stuff/SprDiagDashIndicator
@onready var strumBar = $Strumbar/Control/spr_strumbar/AnimationPlayer
@onready var in_game_rank = $InGameRank/Node2D
@onready var canvas_layer = $CanvasLayer
@onready var combo = $CanvasLayer/stuff/Combo
@onready var characterPortrait
@onready var characterHudPortrait

#PlayerArticles
@onready var bullet = preload("res://Objects/PlayerArticles/Bullet.tscn")

#Hitboxes
@onready var puncHitbox = $PunchHitbox/CollisionShape2D
@onready var airRollHitbox = $AirRollHitbox/CollisionShape2D

func _ready():
	dustParticles.emitting = true
	$DashLine.set_process(false)
	$DashLinePhantom.set_process(false)
	Initialization()
	SpeedrunTimer.loading = false


func _physics_process(delta):
	if (playerSprite != null):
		#if (CharaHandler.debugControlsEnabled):
			#debugStuff(delta)
		#phantomTimeManager()
		freezeManage(delta)
		platformBoostManager(delta)
		cameraAndHudStuff(delta)
		squashAndStretch(delta)
		if (!inCountdown):
			gameRankUpdate()
			cameraSmoothingCheck()
			slopeSpriteFix(delta)
			victoryManager()
			stompBlockBreackingManager()
			inputStuff()
			rayCastManager()
			isGroundedCheck()
			#dashLineStuff(delta)
			playerFacingDirection()
		if (loading):
			createAfterImageBs()
			spawn_dust(4)
			spawn_judgement(4)
			loading = false
			$TransitionAnim.play("in")
			Conductor.loading = false
func Initialization():
	#Connect player to beat signals
	Conductor.beatSignal.connect(playIdle)
	Conductor.beatSignalBPM.connect(countDown)
	Conductor.noteBeatSignalEarly.connect(changePhysicsBasedOnBeatMap)

	cam.position_smoothing_enabled = false
	Conductor.player = self
	Conductor.sceneName = get_tree().current_scene.name
	get_tree().paused = false
	cam.zoom.x = 6.0
	cam.zoom.y = 6.0
	#Setups all of the character's custom props
	if !(CharaHandler.characterData.is_empty()):
		maxWalkVelocity = CharaHandler.characterData["maxWalkVelocity"]
		height = CharaHandler.characterData["jump_velocity"]
		maxJumps = CharaHandler.characterData["maxJumps"]
		dashSpeed = CharaHandler.characterData["maxDashDistance"]
		characterClass = CharaHandler.characterData["character_class"]
		currentCharacter = CharaHandler.character
		characterPortrait = CharaHandler.characterPortrait
		characterHudPortrait = CharaHandler.characterHudPortrait
	else:
		pass
	playerHudJumps.hframes  = CharaHandler.playerHudJumpsNumbah
	playerHudJumps.texture = CharaHandler.playerHudJumps
	lastCheckpoint = [position.x, position.y]
	#assignCharacterStuff()
	call_deferred("assignCharacterStuff")
	Conductor.gamePaused = false

func assignCharacterStuff():
	createCharacterSprite()
	playerSprite.get_material().set("shader_parameter/palette", CharaHandler.playerMaterial)
	playerSprite.show()
	playerSprite.play()
	var mat = playerSprite.get_material().get("shader_parameter/palette")
	playerHudPortrait.texture = characterHudPortrait
	playerHudPortrait.get_material().set("shader_parameter/palette", mat)
	tripNumber = 0
	playIdle()
	dashLineColorSetup()
		
func chargeManager():
	if (playerSprite != null):
		if (!storedCharge):
			currentActionBoost = actionBoost
			storedCharge = true
			playerSprite.get_node("chargeEffect").visible = true
			playerSprite.get_node("chargeSteam").emitting = true
			powerChargeSfx.play()
			phantomActivationSfx.play()

func deactivateCharge():
	if (CharaHandler.character == "Lane"):
		storedCharge = false
		playerSprite.get_node("chargeEffect").visible = false
		playerSprite.get_node("chargeSteam").emitting = false
		currentActionBoost = 0.0

func victoryManager():
	if stateMachine.state == stateMachine.states.win:
		combo.hide()
		Conductor.levelFinished = true
		$CanvasLayer/stuff/TimerText.hide()
		$CanvasLayer/stuff/TooNice.hide()
		in_game_rank.hide()
		$Strumbar.hide()
		playerHudDash.hide()
		playerHudDiagDash.hide()
		playerHudIcon.hide()
		playerHudJumps.hide()
		playerHudPortrait.hide()
		$CanvasLayer/stuff/TrickNam.hide()
		$CanvasLayer/stuff/Tricks.hide()
	else:
		if Conductor.combo >= 7 and !combo.visible:
			combo.show()

func squashAndStretch(delta):
	if (abs(playerSprite.scale.x) != 1):
		playerSprite.scale.x = lerp(playerSprite.scale.x, 1.0*facing, (0.2*60)*delta)
	if (playerSprite.scale.y != 1):
		playerSprite.scale.y = lerp(playerSprite.scale.y, 1.0, (0.2*60)*delta)

func playerFacingDirection():
	if facing == 1:
		#$SprAltItems.position.x = -11
		#$SprAltItems.scale.x = 1
		puncHitbox.position.x = 15.163
		rayW.target_position.y = 14
		rayWTwo.target_position.y = 14
		bulletRay.target_position.x = 34
	else:
		#$SprAltItems.position.x = 11
		#$SprAltItems.scale.x = -1
		puncHitbox.position.x = -15.163
		rayW.target_position.y = -14
		rayWTwo.target_position.y = -14
		bulletRay.target_position.x = -34

func isGroundedCheck():
	if (is_on_floor()):
		wasGrindin = false
		diagDashNumber = 1
		if (!punishTrip):
			tripNumber = 0
		if (CharaHandler.effectsEnabled):
			if (stateMachine.state == stateMachine.states.dash or stateMachine.state == stateMachine.states.walk):
				if (velocity.x > 1 or velocity.x < -1) and !is_on_wall():
					dustParticles.set_emitting(true)
				else:
					dustParticles.set_emitting(false)
			else:
				dustParticles.set_emitting(false)

			dustParticles.position.x = -15 * playerSprite.scale.x
	else:
		if (jumpNumber == 1):
			jumpNumber = 2
		dustParticles.set_emitting(false)

func inputStuff():
	
	if currentCharacter == "May":
		if (Input.is_action_just_released("dash")):
			running = false
	
	if (Input.is_action_just_pressed("pause")):
		if (!win):
			if (!get_tree().paused):
				Conductor.lastSongPos = Conductor.get_playback_position()
				Conductor.gamePaused = true
				get_tree().paused = true
				pauseMenuAnim.get_parent().paused = true
				pauseMenuAnim.play("Pause")
	if (Input.is_action_just_pressed("ui_accept") and win):
		if (!exitingScene):
			exitingScene = true
			animPlayer.play("FadeIn")
#				print("trigger fade and go to world select")

#func _notification(what):
	#match what:
		#NOTIFICATION_APPLICATION_FOCUS_OUT :
			#if (!win):
				#if (!get_tree().paused):
					#Conductor.lastSongPos = Conductor.get_playback_position()
					#get_tree().paused = true
					#pauseMenuAnim.get_parent().paused = true
					#pauseMenuAnim.play("Pause")

func rayCastManager():

	if (rayWThree.is_colliding()):
		var collider = rayWThree.get_collider().name
		
		if collider.begins_with("JumpBoostPlat"):
			jumpBoostPawaaaa = 350

		punishTrip = false
		if (!punishTrip):
			tripNumber = 0
	else:
		jumpBoostPawaaaa = 0
	if (rayWThree.is_colliding() and jumpNumber != 1):
		punishTrip = false
		if (!punishTrip):
			tripNumber = 0

func platformBoostManager(delta):
	if platformBoosted:
		boostedJunmpParticles.emitting = true

	if velocity.y >= 0 and platformBoosted:
		platformBoosted = false
		boostedJunmpParticles.emitting = false

	if lmao: # Variable used for when you mess up a platform boosted jump
		lmaoCounter -= (1 * 60) * delta

func stompBlockBreackingManager():
	if $breakableRaycast.is_colliding():
		var coll = $breakableRaycast.get_collider()
		if coll != null and coll.get_name() == "BreakableArea":
			if stateMachine.state == stateMachine.states.stomp:
				coll.get_parent().destroy()

func gameRankUpdate():
	in_game_rank.deaths = deaths
	in_game_rank.parries = parries
	in_game_rank.timeElapsed = timeElapsed

func cameraSmoothingCheck():
	if !checkedForCamSmoothing:
		if camTimer <= 0:
			cam.position_smoothing_enabled = UserData_Handler.default_data["cameraSmoothing"]
	
func cameraAndHudStuff(delta):
	#Whenever there's a tutorial dialogue active, fades the strumbar abit
	#if (reading):
		#strumBar.modulate.a = 0.8
	#else:
		#strumBar.modulate.a = 1

	playerHudJumps.frame = jumpNumber - 1
	playerHudDash.frame = dashNumber - 1
	playerHudDiagDash.frame = diagDashNumber - 1
		
	if countNumb >= 3:
		inCountdown = false
		$CanvasLayer2/SprLevelCountdown.scale.x += (0.05 * 60) * delta
		$CanvasLayer2/SprLevelCountdown.scale.y += (0.05 * 60) * delta
		$CanvasLayer2/SprLevelCountdown.modulate.a -= (0.05 * 60) * delta
		
	var target_zoom_x = 2.0
	if (cam.zoom.x > target_zoom_x and !hitStopActive):
		cam.zoom.x = lerp(cam.zoom.x, target_zoom_x, (0.05 * 60) * delta)
		cam.zoom.y = cam.zoom.x
	if camTimer > 0:
		camTimer -= delta
	if (rankAppearTimer) > 0:
		in_game_rank.modulate.a = 0
		rankAppearTimer -= delta
	else:
		if in_game_rank.modulate.a < 1: 
			in_game_rank.modulate.a += 0.05
	
func dashLineColorSetup():
	match (currentCharacter):
		"Karu":
			dashLineColorPick("00000000", "ffd03136", "ffd03179", "ffd03136")
		"Froo":
			dashLineColorPick("00000000", "54cd0036", "54cd0079", "54cd0036")
		"Liz":
			dashLineColorPick("00000000", "ff3cff36", "ff3cff79", "ff3cff36")
		"May":
			dashLineColorPick("00000000", "0093eb36", "0093eb79", "ffd03136")

func dashLineColorPick(colorOne, colorTwo, colorThree, colorFour):
	var grad = Gradient.new()
	grad.set_color(0, colorOne)
	grad.add_point(0.243, colorTwo)
	grad.add_point(0.744, colorThree)
	grad.set_color(3, colorFour)
	$DashLine.gradient = grad

func dashLineStuff(delta):
	if ( velocity.y > (200 * Conductor.singleFramephysicsSpeedMultiplier) or stateMachine.state == stateMachine.states.dash or platformBoosted) and !inSnowBall:
		if (phantomTime > 0):
			$DashLinePhantom.trailLength = lerp(float($DashLinePhantom.trailLength), 15.0, (0.5*60)*delta)
			$DashLinePhantom.show()
			dashLine.hide()
		else:
			$DashLinePhantom.hide()
			dashLine.trailLength = lerp(float(dashLine.trailLength), 15.0, (0.5*60)*delta)
			dashLine.show()
	else:
		if (phantomTime > 0):
			dashLine.hide()
			$DashLinePhantom.trailLength = lerp(float($DashLinePhantom.trailLength), 0.0, (0.2*60)*delta)
			if ($DashLinePhantom.trailLength < 1):
				$DashLinePhantom.hide()
		else:
			$DashLinePhantom.hide()
			dashLine.trailLength = lerp(float(dashLine.trailLength), 0.0, (0.2*60)*delta)
			if (dashLine.trailLength < 1):
				dashLine.hide()

func phantomTimeManager():
	if (phantomTime > 0):
		phantomTime -= (phantomTimeDecrease * 60) * get_physics_process_delta_time()

	#if Input.is_action_just_pressed("neuronActivation"):
		#if (!phantomDashOnCoolDown):
			#if !canPhantomDash:
				#phantomParticles.emitting = true
				#phantomActivationSfx.play()
				#canPhantomDash = true
			#else:
				#phantomParticles.emitting = false
				#canPhantomDash = false
	if (phantomDashOnCoolDown):
		phantomParticles.emitting = false
		canPhantomDash = false

func _applyGravity():
	if currentCharacter == "May" and stateMachine.state != stateMachine.states.dash:
		floor_snap_length = 14
	if !debugModeActive:
		jumpsp = height + jumpBoostPawaaaa
		gravity = 700
		if (currentCharacter != "May"):
			if not is_on_floor() and !hitStopActive and stateMachine.state != stateMachine.states.dash:
				if (jumpNumber == 1):
					jumpNumber = 2
				if (!CharaHandler.characterData.is_empty()):
					height = CharaHandler.characterData["jump_velocity"]
				else:
					height =  40
				velocity.y += gravity * Conductor.singleFramephysicsSpeedMultiplier * get_physics_process_delta_time() * Conductor.singleFramephysicsSpeedMultiplier
			else:
				if (jumpNumber == 1):
					jumpNumber = 1
		else:
			if not is_on_floor() and !hitStopActive:
				if (jumpNumber == 1):
					jumpNumber = 2
				if (!CharaHandler.characterData.is_empty()):
					height = CharaHandler.characterData["jump_velocity"]
				else:
					height =  40
				velocity.y += gravity * Conductor.singleFramephysicsSpeedMultiplier * get_physics_process_delta_time() * Conductor.singleFramephysicsSpeedMultiplier
				if currentCharacter == "May" and stateMachine.state == stateMachine.states.dash:
					oldVelocityVertical += gravity * Conductor.singleFramephysicsSpeedMultiplier * get_physics_process_delta_time() * Conductor.singleFramephysicsSpeedMultiplier
			else:
				if (jumpNumber == 1):
					jumpNumber = 1

func changePhysicsBasedOnBeatMap():
	stateMachine.cooldown = 0
	if GlobalDelta.lastDelta != Conductor.singleFramephysicsSpeedMultiplier:
		velocity.y *= float(Conductor.singleFramephysicsSpeedMultiplier) / GlobalDelta.lastDelta
		oldVelocity *= float(Conductor.singleFramephysicsSpeedMultiplier) / GlobalDelta.lastDelta
	if inCountdown:
		inCountdown = false
	maxWalkVelocity = CharaHandler.characterData["maxWalkVelocity"] * Conductor.singleFramephysicsSpeedMultiplier
	dashSnapTimerDecrease = 0.1 * Conductor.singleFramephysicsSpeedMultiplier
	phantomTimeDecrease = 0.1 * Conductor.singleFramephysicsSpeedMultiplier
	afterImageTimer.wait_time = 0.2 / Conductor.singleFramephysicsSpeedMultiplier

func freezeManage(delta):
	if (hitStopTimer > 0):
		if !(platformBoosted or jumpFromSnowBall):
			velocity.y = 0
			velocity.x = 0
		else:
			if jumpFromSnowBall:
				previousVelocityX = velocity.x 
				previousVelocityY = velocity.y
				jumpFromSnowBall = false
				velocity.y = 0
				velocity.x = 0

		playerSprite.speed_scale = 0
		hitStopTimer -= (hitStopDecreaseSpeed * 60) * delta

	else:
		if hitStopActive:
			hitStopActive = false
			if !platformBoosted:
				#print("grrahhh")
				velocity.x += previousVelocityX 
				velocity.y += previousVelocityY
		previousVelocityX = 0
		previousVelocityY = 0
		hitStopTimer = 0
		hitStopDecreaseSpeed = 0
		if !platformBoosted:
			speedlines.hide()

func hitStop(timeScale, duration):
	stateMachine.parryCooldown = 0
	hitStopActive = true
	hitStopTimer = duration
	hitStopDecreaseSpeed = timeScale

func _trip(_delta):
	stompDropKick = false
	hasWallJumped = false
	wallJumpTimer = 0
	playerSprite.scale.x = facing
	if !hitStopActive:
		_applyGravity()
		var direction = Input.get_axis("left", "right")
		if direction != 0:
			facing = direction

		velocity.x = facing * (TRIP_SPEED_MULTIPLIER * maxVelocity)/16 * Conductor.singleFramephysicsSpeedMultiplier
	move_and_slide()

func slopeSpriteFix(delta):
	if (!is_on_floor() and CharaHandler.character == "Applesauce"):
		playerSprite.offset.y = lerp(playerSprite.offset.y, 0.0, (0.2 * 60) * delta)
		dustParticles.position.y = 12
	if (is_on_floor() and CharaHandler.character == "Applesauce"):
		if (get_floor_normal()[0] != 0):
			isOnSlope = true
			if (get_floor_normal()[0] > 0):
				if (facing == -1):
					playerSprite.offset.y = lerp(playerSprite.offset.y, 10.5, (0.2 * 60) * delta)
					dustParticles.position.y = 29
				if (facing == 1):
					playerSprite.offset.y = lerp(playerSprite.offset.y, 5.0, (0.5 * 60) * delta)
					dustParticles.position.y = 12
			else:
				if (facing == -1):
					playerSprite.offset.y = lerp(playerSprite.offset.y, -2.0, (0.5 * 60) * delta)
					dustParticles.position.y = 12
				if (facing == 1):
					playerSprite.offset.y = lerp(playerSprite.offset.y, 5.0, (0.5 * 60) * delta)
					dustParticles.position.y = 29

		else:
			isOnSlope = false
		if (!isOnSlope):
			playerSprite.offset.y = lerp(playerSprite.offset.y, 0.0, (0.2 * 60) * delta)
			dustParticles.position.y = 12

func _applyMovement(delta):
	if (running):
		runSpeed = 2.5
		#print("jdfiaj")
	else:
		runSpeed = 0.0

	if !platformBoosted:
		if (!hasWallJumped):
			var direction = Input.get_axis("left", "right")
			var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")

			if (!canWallJump):
				if !(stompDropKick):
					if input_direction != 0:
						facing = sign(input_direction)
			if (!canWallJump):
				playerSprite.scale.x = facing
			if direction:
				leftRightControlStuff(direction)
			else:
				if get_tree().current_scene.name != "FROSTFALL":
					
					if is_on_floor():
						velocity.x = move_toward(velocity.x, 0, (SPEED) * Conductor.physicsSpeedMultiplier)
					else:
						if !(stompDropKick):
							if !wasGrindin:
								velocity.x = move_toward(velocity.x, 0, (SPEED)  * Conductor.physicsSpeedMultiplier )
							else:
								velocity.x = ((2.0*Conductor.singleFramephysicsSpeedMultiplier)*75)*facing
				else:
					var friction
					if is_on_floor():
						friction = 8
						velocity.x = move_toward(velocity.x, 0, ((SPEED)-friction)  * Conductor.physicsSpeedMultiplier )
					else:
						friction = 0
						if !(stompDropKick):
							if !wasGrindin:
								velocity.x = move_toward(velocity.x, 0, (SPEED)  * Conductor.physicsSpeedMultiplier )
							else:
								velocity.x = ((2.0*Conductor.singleFramephysicsSpeedMultiplier)*75)*facing
		vertical_corner_correction(10)
	else:
		velocity.x = 0
		oldVelocity = 0
		oldVelocityVertical = 0
	move_and_slide()
		#Applies regular movement when grounded or airborne
	if characterClass != "Gunner":
		wallJumpStuff(delta)

func leftRightControlStuff(direction):
	if direction:
		if is_on_floor() and !is_on_wall():
			velocity.x = direction * ((maxWalkVelocity + runSpeed) * 30)
		else:
			if (currentCharacter == "May"):
				if !stompDropKick:
					velocity.x = direction * ((maxWalkVelocity + runSpeed) * 30)
			else:
				if (!wasGrindin):
					velocity.x = direction * ((maxWalkVelocity + runSpeed) * 42)
				else:
					velocity.x = direction * (2*75)
	
func cameraWin():
	cam.offset.y = lerp(float(cam.offset.y), 50.0, (0.1*60)*get_physics_process_delta_time())

func wallJumpStuff(delta):

	if !(benboRay1.is_colliding() or benboRay2.is_colliding()) or is_on_floor():
		canWallJump = false
	
	#if !(currentCharacter == "Nix" or currentCharacter == "May" or currentCharacter == "Lane"):
		#if (hasWallJumped and !(benboRay1.is_colliding() or benboRay2.is_colliding())):
			#if (wallJumpTimer > 0):
				#wallJumpTimer -= (wallJumpTimerDecreaseRate) * delta
			#else:
				#wallJumpTimerDecreaseRate = 80.0
				#hasWallJumped = false
	#else:
	if (hasWallJumped):
		if (wallJumpTimer > 0):
			wallJumpTimer -= (wallJumpTimerDecreaseRate * Conductor.singleFramephysicsSpeedMultiplier) * delta
		else:
			wallJumpTimerDecreaseRate = 75.0
			hasWallJumped = false

	if !(currentCharacter == "Nix" or currentCharacter == "May" or currentCharacter == "Lane"):
		if (benboRay1.is_colliding() and !is_on_floor()):
			var wallCollision = benboRay1.get_collider()
			if (wallCollision.name.begins_with("debugWallVine")):
				if ((Input.is_action_pressed("right")) or !canWallJump):
					if stateMachine.state == stateMachine.states.dash:
						stateMachine.set_state(stateMachine.states.wallSliding)
					canWallJump = true
					diagDashDown = false
					diagDashUp = false
					has_usedDashDirChange = false
					has_usedVerticalDashDirChange = false
					facing = -1
					playerSprite.scale.x = facing

		if (benboRay2.is_colliding() and !is_on_floor()):
			var wallCollisionLeft = benboRay2.get_collider()
			if (wallCollisionLeft.name.begins_with("debugWallVine")):
				if ((Input.is_action_pressed("left")) or !canWallJump):
					if stateMachine.state == stateMachine.states.dash:
						stateMachine.set_state(stateMachine.states.wallSliding)
					canWallJump = true
					diagDashDown = false
					diagDashUp = false
					has_usedDashDirChange = false
					has_usedVerticalDashDirChange = false
					facing = 1
					playerSprite.scale.x = facing
	else:
		if (benboRay1.is_colliding() and !is_on_floor()):
			if (CharaHandler.character == "May"):
				if (playerSprite.get_animation() == "DropKick"):
					playerSprite.play("Stomp")
			if !(stateMachine.state == stateMachine.states.dash or stateMachine.state == stateMachine.states.stomp):
				if (Input.is_action_pressed("right")):
					if (CharaHandler.character != "Lane"):
						canWallJump = true
						diagDashDown = false
						diagDashUp = false
						has_usedDashDirChange = false
						has_usedVerticalDashDirChange = false
						facing = -1
						playerSprite.scale.x = facing
					else:
						if (Input.is_action_pressed("up")):
							canWallJump = true
							diagDashDown = false
							diagDashUp = false
							has_usedDashDirChange = false
							has_usedVerticalDashDirChange = false
							facing = -1
							playerSprite.scale.x = facing

		if (benboRay2.is_colliding() and !is_on_floor()):
			if (CharaHandler.character == "May"):
				if (playerSprite.get_animation() == "DropKick"):
					playerSprite.play("Stomp")
			if !(stateMachine.state == stateMachine.states.dash or stateMachine.state == stateMachine.states.stomp):
				if (Input.is_action_pressed("left")):
					if (CharaHandler.character != "Lane"):
						canWallJump = true
						diagDashDown = false
						diagDashUp = false
						has_usedDashDirChange = false
						has_usedVerticalDashDirChange = false
						facing = 1
						playerSprite.scale.x = facing
					else:
						if (Input.is_action_pressed("up")):
							canWallJump = true
							diagDashDown = false
							diagDashUp = false
							has_usedDashDirChange = false
							has_usedVerticalDashDirChange = false
							facing = 1
							playerSprite.scale.x = facing
func newDashMovement(_delta):
	if (oldVelocity < 0 and facing != -1):
		facing = -1
		playerSprite.scale.x = facing
	if (oldVelocity > 0 and facing != 1):
		facing = 1
		playerSprite.scale.x = facing

	if CharaHandler.character != "May":
		_applyGravity()
		if (dashSnapTimer > 0):
			dashSnapTimer -= (dashSnapTimerDecrease * 60) * _delta
		if (abs(oldVelocity) < Conductor.singleFramephysicsSpeedMultiplier * 70):
			has_dashed = false
		if (rayWThree.is_colliding() and !diagDashDown):
			if dashSnapTimer <= 0:
				groundSnap()
	#			print("ahoy")
		rayW.force_raycast_update()
		rayWTwo.force_raycast_update()
		vertical_corner_correction(9)

		if $breakableRaycast.is_colliding():
			if $breakableRaycast.get_collision_normal() != Vector2(0, -1):
				floor_snap_length = 32
			else:
				floor_snap_length = 14
		if !(diagDashDown and diagDashUp) and !isOnSlope:
			velocity.y = 0
		if ((rayW.is_colliding() or rayWTwo.is_colliding())) and !(rayW.is_colliding() and rayWTwo.is_colliding()):
			var collider = rayW.get_collision_normal()
			if collider.y == 0:
				if playerSprite.scale.x == -1:
					if is_on_floor():
						position.x -= 8
					else:
						if !diagDashDown:
							if (time_remaining <= 0):
								position.x -= 8
								diagDashUp = false
					if velocity.y < 0:
						position.y -= 2
					elif velocity.y > 0:
						if !(diagDashUp or diagDashDown):
							position.y += 5
	#				else:
	#					if (diagDashUp):
	#						position.y -= 2
	#						print("what the FUCK")
				else:
					if is_on_floor():
						position.x += 8
					else:
						if !diagDashDown:
							if (time_remaining <= 0):
								position.x += 8
								diagDashUp = false
					if velocity.y < 0:
						position.y -= 2
					elif velocity.y > 0:
						if !(diagDashUp or diagDashDown):
							position.y += 5
	#				else:
	#					if (diagDashUp):
	#						position.y -= 2
	#						print("what the FUCK")
			else:
				isOnSlope = true

		var spd = Conductor.singleFramephysicsSpeedMultiplier / 17.0
		oldVelocity = lerpf(oldVelocity, 0.0, (spd * 60) * _delta)
		velocity.x = oldVelocity

		oldVelocityVertical = lerpf(oldVelocityVertical, 0.0, (spd * 60) * _delta)
		velocity.y = oldVelocityVertical
		
	#this is cool but it breaks the game, gives you infinite dashes if you know how to use it properly
	#i could fix this easily but i'm feeling insanely lazy rn so no thanks, maybe 4 the final game

	#	if !has_usedVerticalDashDirChange  and (oldVelocityVertical > 100 or oldVelocityVertical < -100):
	#		if Input.is_action_just_pressed("up"):
	#			diagDashDown = false
	#			diagDashUp = true
	#			oldVelocityVertical *= -1
	#			has_usedVerticalDashDirChange = true
	#			print("listen here you little shit")
	#
	#		if Input.is_action_just_pressed("down"):
	#			diagDashUp = false
	#			diagDashDown = true
	#			oldVelocityVertical *= -1
	#			has_usedVerticalDashDirChange = true
	#			print("listen here you little shit")
		
		var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		
		if input_direction != 0 and !has_usedDashDirChange and (oldVelocity > 10 or oldVelocity < -10):
			if (playerSprite.scale.x != sign(input_direction)):
				playerSprite.scale.x = sign(input_direction)
				oldVelocity *= -1
				has_usedDashDirChange = true
		#if input_directionCtr != 0 and !has_usedDashDirChange and (oldVelocity > 10 or oldVelocity < -10):
			#if (playerSprite.scale.x != sign(input_directionCtr)):
				#playerSprite.scale.x = sign(input_directionCtr)
				#oldVelocity *= -1
				#has_usedDashDirChange = true
	#	if (facing != playerSprite.scale.x):
	#		velocity.x = -oldVelocity
	#	else:
	#		velocity.x = oldVelocity

		corner_correction(14)
		
		#Special case for diagonal dash down
		
		if is_on_floor():
			dashAnimationHandler("Dash")
		else:
			if (oldVelocityVertical > 0):
				if $breakableRaycast.is_colliding():
					if $breakableRaycast.get_collision_normal() != Vector2(0, -1):
						dashAnimationHandler("Dash")
					else:
						dashAnimationHandler("Dash_Down")
				else:
					dashAnimationHandler("Dash_Down")
				isInDashAnim = false
			elif (oldVelocityVertical < 0):
				dashAnimationHandler("Dash_Up")
				isInDashAnim = false
			else:
	#			print(diagDashUp)
				if !(diagDashDown or diagDashUp):
	#				print("what the FUCK")
					if CharaHandler.character == "Froo":
						dashAnimationHandler("Dash_AirTwo")
					else:
						dashAnimationHandler("Dash_Air")

		move_and_slide()
	else:
		#MayDash
		_applyGravity()
		if $breakableRaycast.is_colliding():
			if oldVelocityVertical >= 0:
				var spd = Conductor.singleFramephysicsSpeedMultiplier / 17.0
				oldVelocity = lerpf(oldVelocity, 0.0, (spd * 60) * _delta)
			if $breakableRaycast.get_collision_normal() != Vector2(0, -1):
				floor_snap_length = 32
			else:
				floor_snap_length = 14
		
		if is_on_floor():
			corner_correction(16)
			playerSprite.offset.y = 2
			var spd = Conductor.singleFramephysicsSpeedMultiplier / 27.0
			var walkSpd = (facing * ((maxWalkVelocity + runSpeed) * 40))
			if (abs(oldVelocity / 2) < Conductor.singleFramephysicsSpeedMultiplier * 60):
				has_dashed = false
			oldVelocity = lerpf(oldVelocity, walkSpd, (spd * 60) * _delta)
			if abs(oldVelocity) <= abs(walkSpd):
				stateMachine.dashCancelProps()
		else:
			corner_correction(13)
			if playerSprite.get_animation() != "Dash" and !airRollAttack:
				playerSprite.play("Dash")
				
		velocity.x = oldVelocity / 2
		velocity.y = oldVelocityVertical
		
		move_and_slide()

func grounded(delta):
	#This is the code that knows is the player is in the GROUNDED state
	#(When you trip and the character sits on the ground for a bit before getting up)
	_applyGravity()
	
	if get_tree().current_scene.name != "FROSTFALL":
		velocity.x = move_toward(velocity.x, 0, SPEED/1.5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/3)
	if (groundedTime > 0):
		groundedTime -= (1*60)*delta
	move_and_slide()

func activateDeactivateHitbox(activate):
	puncHitbox.set_deferred("disabled", activate)

func dashAnimationHandler(animName):
	var curFrame = playerSprite.get_frame()
	if (playerSprite.get_animation() != animName):
			playerSprite.play(animName)
			playerSprite.frame = curFrame

func debugStuff(delta):
	if Input.is_action_just_pressed("debugDisableBeat"):
		if !debugModeActive:
			velocity.x = 0
			velocity.y = 0
			debugModeActive = true
			$CollisionShape2D.set_deferred("disabled", true)
		else:
			debugModeActive = false
			$CollisionShape2D.set_deferred("disabled", false)
	
	if debugModeActive:
		
		if Input.is_action_just_pressed("disableHud"):
			if $CanvasLayer.visible:
				$CanvasLayer.visible = false
				$InGameRank.visible = false
				Conductor.emit_signal("disableChartDisplay")
			else:
				$CanvasLayer.visible = true
				$InGameRank.visible = true
				Conductor.emit_signal("disableChartDisplay")
			
		if Input.is_action_just_pressed("disablePlayer"):
			if playerSprite.visible:
				playerSprite.visible = false
			else:
				playerSprite.visible = true
		
		velocity.x = 0
		velocity.y = 0
		if Input.is_action_pressed("parry"):
			debugMovementSpeed = 15
		else:
			debugMovementSpeed = 5

		if Input.is_action_pressed("freeFlyModeSlowDown"):
			if !Input.is_action_pressed("parry"):
				debugMovementSpeed = 1
			else:
				debugMovementSpeed = 5
		if Input.is_action_just_released("freeFlyModeSlowDown"):
			debugMovementSpeed = 5

		if Input.is_action_pressed("up"):
			position.y -= (debugMovementSpeed * 60) * delta
		if Input.is_action_pressed("down"):
			position.y += (debugMovementSpeed * 60) * delta
		if Input.is_action_pressed("left"):
			position.x -= (debugMovementSpeed * 60) * delta
		if Input.is_action_pressed("right"):
			position.x += (debugMovementSpeed * 60) * delta

func playIdle():
#	print("???")
	if lmaoCounter < 0:
		die = true
		lmaoCounter = 0
		lmao = false

	if stateMachine.state == stateMachine.states.idle and !talking:
		playerSprite.play("Idle")
#	animPlayer.play("Idle")

func countDown():
	if Conductor.currentBeat > 1:
		countNumb += 1
	if countNumb < 4 and Conductor.currentBeat > 1:
		$CanvasLayer2/SprLevelCountdown.frame = countNumb

func stopTalk():
	talking = false

func groundSnap():
	if (!is_on_floor() and rayWThree.is_colliding()):
#		print("waaa")
		punishTrip = false
		if (!punishTrip):
			tripNumber = 0
		var floor_y = rayWThree.get_collision_point().y
		var collisionBox = collision.shape
		var player_y = position.y + collisionBox.size.y / 2
		
		if floor_y > player_y:
			oldVelocityVertical = 0
			position.y = floor_y - collisionBox.size.y / 2
			jumpNumber = 1

func corner_correction(amount):
#	if velocity.y == 0:
	if (stateMachine.state != stateMachine.states.grounded):
		var delta = get_physics_process_delta_time()
		if test_move(global_transform, Vector2(velocity.x*delta,0)):
			for i in range(1,amount*2+1):
				for j in [-1.0,1.0]:
					if !test_move(global_transform.translated(Vector2(0,i*j/2)),
						Vector2(velocity.x*delta,0)):
						translate(Vector2(0,i*j/2))
	#					print("corner")
						if diagDashUp:
							velocity.y = 0
							oldVelocityVertical = 0
							diagDashUp = false
						#else:
							#velocity.y = 0
						return

func vertical_corner_correction(amount):
	if velocity.y < 0 and stateMachine.state == stateMachine.states.jump:
		
		var delta = get_physics_process_delta_time()
		if test_move(global_transform, Vector2(0,velocity.y*delta)):
			for i in range(1,amount*2+1):
				for j in [-1.0,1.0]:
					if !test_move(global_transform.translated(Vector2(i*j/2,0)),
						Vector2(0,velocity.y*delta)):
						translate(Vector2(i*j/2,0))
						if velocity.x * j < 0: velocity.x = 0
						#print("ayo")
						return
						
func parriedEnemy(posed):
	parrySfx.play()
	if posed:
		spawn_parryFX(facing, true)
		cam.zoom.x = 2.15
		cam.zoom.y = 2.15
	else:
		spawn_parryFX(facing, false)
		shake(0.2, 1)
		speedlines.show()
		var beats_per_second = Conductor.bpm / 60.0
		var seconds_per_beat = 0.7 / beats_per_second
		var hitStopLength = 5.4 / 4.0 * seconds_per_beat
		hitStop(0.05, hitStopLength)
		
		cam.zoom.x = 2.35
		cam.zoom.y = 2.35

#func spawn_phantom(distnc):
	#var idPhantom = phantomPlayer.instantiate()
	#if is_on_floor():
		#idPhantom.wasOnGround = true
	#else:
		#idPhantom.wasOnGround = false
	#idPhantom.scale.x= playerSprite.scale.x
	#idPhantom.posx = position.x + (-distnc * idPhantom.scale.x)
	#idPhantom.posy = position.y
	#idPhantom.animation = "Idle"
	#idPhantom.speed_scale = playerSprite.speed_scale
	#idPhantom.top_level = true
	#idPhantom.parent = self
	#add_child(idPhantom)
	
func spawn_dust(frame):
	if (CharaHandler.beatHitsEnabled and !punishTrip):
		for i in $jumpDustPool.get_children():
			if (i.canBeReused):
				i.canBeReused = false
				i.top_level = true
				i.position = position
				i.play("default")
				i.visible = true
				if (frame != 0):
					i.frame = 3
				break
		
func parry_func(_delta):
	if platformBoosted:
		_applyGravity()
	else:
		velocity.y = 0
	velocity.x *= 0.85
	move_and_slide()
	
func spawn_parryFX(_dir, _posed):
	if (CharaHandler.effectsEnabled):
		velocity.x = 0
		velocity.y = 0
		oldVelocity = 0
		oldVelocityVertical = 0
		#var parryId
#
		#parryId = parryFx.instantiate()
		#parryId.posx = position.x
		#parryId.posy = position.y
		#if _posed:
			#parryId.fx = "strikePose"
		#else:
			#parryId.fx = "default"
			#if dir == 1:
				#parryId.posx += 28
			#else:
				##print("pero eres hijo de puta?")
				#parryId.posx -= 28
#
		#parryId.top_level = true
		#call_deferred("add_child", parryId)

func createParryText(text):
	createComboTimePlusOrLessText(text, true) #what the fuck am i doing

func createComboTimePlusOrLessText(txtToShow, positive):
	if (CharaHandler.effectsEnabled):
		var id = timePlusOrLessText.instantiate()
		id.textToShow = txtToShow
		id.good = positive
		id.position.y += 20
		id.position.x += 18
		$CanvasLayer/stuff/TimerText.call_deferred("add_child", id)

func checkPoint(xCoord, yCoord):
	lastCheckpoint = [xCoord, yCoord-10]

func spawn_bullet(dir):
	var bulletId
	bulletId = bullet.instantiate()
	if bulletRay.is_colliding():
#		print("GREAAAAAAHHHH")
		bulletId.breakInstantly = true
		bulletId.position.x = bulletRay.get_collision_point().x
	else:
		if dir == 1:
			bulletId.position.x = position.x + 24
		else:
			bulletId.position.x = position.x - 14
	bulletId.dir = dir
	bulletId.position.y = position.y + 4
	
	call_deferred("add_child", bulletId)

func deathFunc(delta):
	if (deathTimer == 20):
		#dashLine.trailLength = lerp(float(dashLine.trailLength), 0.0, (0.9*60)*delta)
		#if phantomTime > 0:
			#$DashLinePhantom.trailLength = lerp(float($DashLinePhantom.trailLength), 0.0, (0.9*60)*delta)
		Conductor.combo = 0
		if firstDeath == 0:
			firstDeath = 1
			in_game_rank.firstDeath = firstDeath
		else:
			deaths += 1
		deathAnim.show()
		deathAnim.frame = 0
		deathAnim.play("default")
		if (parries >= 2):
			parries -= 2
		else:
			parries = 0
		createComboTimePlusOrLessText("-2 tricks :(", false)
		killSfx.play()
	if (deathTimer > 0):
		deathTimer -= (1*60)*delta

func respawnFunc():
	stompDropKick = false
	diagDashDown = false
	diagDashUp = false
	deathTimer = 20
	playerSprite.show()
	deathAnim.hide()
	velocity.x = 0
	velocity.y = 0
	oldVelocity = 0
	oldVelocityVertical = 0
	die = false
	position.x = lastCheckpoint[0]
	position.y = lastCheckpoint[1]
	
func shake(duration, amplitude): #gang
	var start_pos = Vector2(0, 0)
	var timer = get_tree().create_timer(duration)
	while timer.time_left > 0:
		cam.offset = start_pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))
		await(get_tree().process_frame)
	cam.offset = start_pos
	
func comboMilestone():
	if (Conductor.combo > 9 and Conductor.combo <= 99):
		$CanvasLayer/stuff/Combo/ComboEffect.position.x = 76
	elif (Conductor.combo > 99 and Conductor.combo <= 999):
		$CanvasLayer/stuff/Combo/ComboEffect.position.x = 82
	elif (Conductor.combo > 999):
		$CanvasLayer/stuff/Combo/ComboEffect.position.x = 87
	else:
		$CanvasLayer/stuff/Combo/ComboEffect.position.x = 70
	$CanvasLayer/stuff/Combo/ComboEffect.frame = 0
	$CanvasLayer/stuff/Combo/ComboEffect.play("default")
	if Conductor.combo  % 30 == 0 and Conductor.combo > 1:
		var min_pitch = 0.95
		var max_pitch = 1.05
		var random_pitch = randf_range(min_pitch, max_pitch)
		$Too.volume_db = 3
		$Too.play()
		$Too.pitch_scale = random_pitch
		$CanvasLayer/tooNiceAnimPlayer.play("Woaaa")
		Conductor.combo = 0
		timeElapsedManager(true)
		
func timeElapsedManager(good):
	if good:
		$CanvasLayer.time_elapsed -= 3
		timeElapsed -= 3
		createComboTimePlusOrLessText("-3 Seconds!", true)
	else:
		$CanvasLayer.time_elapsed += 5
		timeElapsed += 5
		createComboTimePlusOrLessText("+5 Seconds...", false)
		
func createCharacterSprite():
	var characterInstanceId = load("res://Characters/" + currentCharacter +"/" + currentCharacter + ".tscn").instantiate()
	smoothing.add_child(characterInstanceId)
	playerSprite = get_node("Smoothing2D/"+currentCharacter)

func createAfterImageBs():
	if (CharaHandler.effectsEnabled):
		for i in $afterImagePool.get_children():
			if (i.canBeReused):
				i.canBeReused = false
				i.top_level = true
				i.position = position
				i.scale.x = playerSprite.scale.x
				i.initialization()
				break

func spawn_judgement(judgement):
	for i in $judgementPool.get_children():
		if (i.canBeReused):
			i.canBeReused = false
			if (tripNumber == maxTrips and judgement == 1):
				i.judgement_type = 2
			else:
				i.judgement_type = judgement
			i.top_level = true
			if (judgement != 4):
				i.frame = i.judgement_type
			else:
				i.frame = 0
			i.scale.x = 1
			i.scale.y = 1
			if (judgement == 4):
				i.modulate.a = 0.1
			else:
				i.modulate.a = 1.0
			i.posx = position.x
			i.posy = position.y
			i.visible = true
			break
		

func _on_after_image_timer_timeout():
	if (CharaHandler.effectsEnabled):
		if ( velocity.y > (200 * Conductor.singleFramephysicsSpeedMultiplier) or stateMachine.state == stateMachine.states.dash or platformBoosted) and !inSnowBall:
			if (stateMachine.state != stateMachine.states.win):
				createAfterImageBs()
			#var afI = afterImage.instantiate()
			#if (phantomTime > 0):
				#afI.color = "blue"
			#else:
				#afI.color = "yellow"
func _exit_tree():
	queue_free()

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "FadeIn" and win):
		Conductor.songUnload()
		Conductor.stopSoundEffects = false
		Conductor.stop()
		if get_tree().current_scene.name == "TUTORIAL":
			Conductor.combo = 0
			Conductor.sceneName = "MainMenu"
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
			Conductor.gamePaused = false
		else:
			
			Conductor.combo = 0
			Conductor.emit_signal("destroyNotes")
			Conductor.sceneName = "MainMenu"
			get_tree().change_scene_to_file("res://Scenes/Menus/WorldSelect.tscn")
			Conductor.gamePaused = false


func _on_speedline_timer_timeout():
	speedlines.hide()
