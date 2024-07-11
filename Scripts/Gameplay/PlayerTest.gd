extends CharacterBody2D

const SPEED = 10.0
const JUMP_VELOCITY = -400.0
const SPEED_BPM_MULTIPLIER = 1500
const DASH_SPEED_BPM_MULTIPLIER = 3525
const DASHSPEED = 300.0
const multiplier = 0.2

var jumpBoostPawaaaa = 0
var platformBoosted = false
var platformBoostParticleTime = 40
var maxDashDistance = 40
var height = 40
var gravity = 200
var maxWalkVelocity = 2
var maxVelocity = 6
var facing = 1
var dashTime = 20
var dashNumber = 1
var dashMaxNumber = 3
var diagDashNumber = 1
var diagDashMaxNumber = 3
var jumpNumber = 1
var maxJumps = 3
var diagDashUp = false
var diagDashDown = false
var oldVelocity = 0
var oldVelocityVertical = 0
var dashTimeElapsed = 0.0
var timer_speed
var time_remaining = 15
var has_usedDashDirChange = false

var tripNumber = 0
var maxTrips = 2
var tripTime = 25
var punishTrip = false
var groundedTime = 30
var currentCharacter = "Karu"
var debugBeatMovementDisabled = false
var canWallJump = false
var hasWallJumped = false
var wallJumpTimer = 20
var deathTimer = 20
var inputBeat = false
var die = false
var win = false
var exitingScene = false
var inSnowBall = false

var deaths = 0
var parries = 0
var totalParries = 3
var timeElapsed = 0.0

#var score = 10000 + ((-deaths*500) + ((parries*totalParries)*100) - (time)*10)

var characterClass = "Dasher" #3 classes, Dasher, Gunner, Grappler
var lastCheckpoint

@onready var animPlayer = $AnimationPlayer
@onready var metronome = $Metronome
@onready var jumpSfx = $Jump
@onready var boostedJumpSfx = $BoostedJump
@onready var dashSfx = $Dash
@onready var tripSfx = $Trip
@onready var killSfx = $Death
@onready var parrySfx = $Parry
@onready var stateMachine = $StateMachine
@onready var rayW = $RayCast2D
@onready var rayWTwo = $RayCast2D2
@onready var rayWThree = $RayCast2D3
@onready var bulletRay = $bulletRaycast
@onready var collision = $CollisionShape2D
@onready var dashLine = $DashLine
@onready var dustParticles = $Dust
@onready var parryMarker = $ParryMarker
@onready var cam = $Smoothing2D/Camera2D
@onready var speedlines = $CanvasLayer/SprSpeedLines
@onready var pauseMenuAnim = $PauseMenu/AnimationPlayer
@onready var afterImageTimer = $AfterImageTimer
@onready var boostedJunmpParticles = $BoostedJumpParticles
@onready var deathAnim = $DeathExplosion
@onready var playerHudPortrait = $CanvasLayer/SprHudPortrait
@onready var playerHudIcon = $CanvasLayer/SprDashIcons
@onready var playerHudJumps = $CanvasLayer/SprJumpIndicator
@onready var playerHudDash = $CanvasLayer/SprNormalDashIndicator
@onready var playerHudDiagDash = $CanvasLayer/SprDiagDashIndicator
@onready var strumBar = $Strumbar/Control/spr_strumbar
@onready var in_game_rank = $InGameRank/Node2D
@onready var canvas_layer = $CanvasLayer
@onready var combo = $CanvasLayer/Combo
@onready var checkedForCamSmoothing = false
@onready var reading = false

@onready var parryFx = preload("res://Objects/FX/ParrySuccessFX.tscn")
@onready var jumpDust = preload("res://Objects/FX/JumpDust.tscn")
@onready var bullet = preload("res://Objects/PlayerArticles/Bullet.tscn")
@onready var afterImage = preload("res://Objects/FX/AfterImage.tscn")
@onready var menuSong = preload("res://Music/mus_mainMenu.ogg")
@onready var playerSprite = null
@onready var isOnSlope = false
@onready var characterPortrait
@onready var characterHudPortrait

var rankAppearTimer = 3.75
var inCountdown = false
var countNumb = 0

var isInDashAnim = false
var last_animation = "Dash"

var snap_time = 0.1
var snap_timer = 0.0

var lmao = false
var lmaoCounter = 2

func _ready():
	
	if get_tree().current_scene.name == "TUTORIAL":
		Conductor.songToLoad(115,-1, Conductor.tutorialSong)
	cam.zoom.x = 6.0
	cam.zoom.y = 6.0
	if !(CharaHandler.characterData.is_empty()):
		maxWalkVelocity = CharaHandler.characterData["maxWalkVelocity"]
		height = CharaHandler.characterData["jump_velocity"]
		maxJumps = CharaHandler.characterData["maxJumps"]
		maxVelocity = CharaHandler.characterData["maxDashDistance"]
		characterClass = CharaHandler.characterData["character_class"]
		currentCharacter = CharaHandler.character
		characterPortrait = load(CharaHandler.characterData["portrait"])
		characterHudPortrait = load(CharaHandler.characterData["hudPortrait"])
	else:
		pass
	if maxJumps == 4:
		playerHudJumps.texture = load("res://Sprites/HUD/spr_jumpIndicatorTripleJump.png")
		playerHudJumps.hframes = 4
	elif maxJumps == 2:
		playerHudJumps.texture = load("res://Sprites/HUD/spr_jumpIndicatorSingleJump.png")
		playerHudJumps.hframes = 2
	Conductor.beatSignal.connect(playIdle)
	Conductor.beatSignalBPM.connect(countDown)
	lastCheckpoint = [position.x, position.y]
	playIdle()
	playerSprite = get_node("Smoothing2D/"+currentCharacter)
	playerSprite.get_material().set("shader_parameter/palette", load("res://Characters/"+ CharaHandler.character + "/Palettes/pal_"+str(CharaHandler.alt)+".png"))
	playerSprite.show()
	playerSprite.play()
	var mat = playerSprite.get_material().get("shader_parameter/palette")
	playerHudPortrait.texture = characterHudPortrait
	playerHudPortrait.get_material().set("shader_parameter/palette", mat)
	tripNumber = 0
	SpeedrunTimer.loading = false
func _physics_process(delta):
	if lmao:
		lmaoCounter -= (1 * 60) * delta
	if platformBoosted:
		boostedJunmpParticles.emitting = true
		platformBoostParticleTime -= ( 1 * 60 ) * delta

	if platformBoostParticleTime <= 0 and platformBoosted:
		platformBoosted = false
		platformBoostParticleTime = 40
		boostedJunmpParticles.emitting = false
		
	if (reading):
		strumBar.modulate.a = 0.8
	else:
		strumBar.modulate.a = 1

	playerHudJumps.frame = jumpNumber - 1
	playerHudDash.frame = dashNumber - 1
	playerHudDiagDash.frame = diagDashNumber - 1
		
	if countNumb >= 3:
		inCountdown = false
		$CanvasLayer2/SprLevelCountdown.scale.x += (0.05 * 60) * get_physics_process_delta_time()
		$CanvasLayer2/SprLevelCountdown.scale.y += (0.05 * 60) * get_physics_process_delta_time()
		$CanvasLayer2/SprLevelCountdown.modulate.a -= (0.05 * 60) * get_physics_process_delta_time()
		
	var target_zoom_x = 2.0
	if cam.zoom.x > target_zoom_x:
		cam.zoom.x = lerp(cam.zoom.x, target_zoom_x, (0.1 * 60) * delta)
		cam.zoom.y = cam.zoom.x

	if (rankAppearTimer) > 0:
		in_game_rank.modulate.a = 0
		rankAppearTimer -= delta
	else:
		if in_game_rank.modulate.a < 1: 
			in_game_rank.modulate.a += 0.05
	if (!inCountdown):
		if !checkedForCamSmoothing:
			cam.position_smoothing_enabled = UserData_Handler.default_data["cameraSmoothing"]
		in_game_rank.deaths = deaths
		in_game_rank.parries = parries
		in_game_rank.timeElapsed = timeElapsed

		if stateMachine.state == stateMachine.states.win:
			combo.hide()
			$CanvasLayer/TimerText.hide()
			in_game_rank.hide()
			strumBar.hide()
			playerHudDash.hide()
			playerHudDiagDash.hide()
			playerHudIcon.hide()
			playerHudJumps.hide()
			playerHudPortrait.hide()
		else:
			if Conductor.combo >= 7 and !combo.visible:
				combo.show()
		if $breakableRaycast.is_colliding():
			var coll = $breakableRaycast.get_collider()
			if coll.get_name() == "BreakableArea":
				if stateMachine.state == stateMachine.states.stomp:
					coll.get_parent().destroy()
		if (Input.is_action_just_pressed("customAction") and characterClass == "Gunner"):
			spawn_bullet(facing)
		
		if (Input.is_action_just_pressed("pause")):
			if (!win):
				if (!get_tree().paused):
					Conductor.lastSongPos = Conductor.get_playback_position()
					get_tree().paused = true
					pauseMenuAnim.get_parent().paused = true
					pauseMenuAnim.play("Pause")
		if (Input.is_action_just_pressed("ui_accept") and win):
			if (!exitingScene):
				exitingScene = true
				animPlayer.play("FadeIn")
#				print("trigger fade and go to world select")

		if (rayWThree.is_colliding()):
			var collider = rayWThree.get_collider().name
			
			if collider.begins_with("JumpBoostPlat"):
				jumpBoostPawaaaa = 200
			else:
				jumpBoostPawaaaa = 0
			punishTrip = false
			if (!punishTrip):
				tripNumber = 0
		else:
			jumpBoostPawaaaa = 0
		if (rayWThree.is_colliding() and jumpNumber != 1):
			punishTrip = false
			if (!punishTrip):
				tripNumber = 0
		
		if (Input.is_action_just_pressed("respawn")):
			position.x = lastCheckpoint[0]
			position.y = lastCheckpoint[1]

		if (is_on_floor()):
			diagDashNumber = 1
			if (!punishTrip):
				tripNumber = 0
			if (stateMachine.state == stateMachine.states.dash or stateMachine.state == stateMachine.states.walk):
				if (velocity.x > 1 or velocity.x < -1):
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
		if ( velocity.y > 200 or stateMachine.state == stateMachine.states.dash or platformBoosted):
			dashLine.trailLength = lerp(float(dashLine.trailLength), 15.0, (0.5*60)*delta)
			dashLine.show()
		else:
			dashLine.trailLength = lerp(float(dashLine.trailLength), 0.0, (0.2*60)*delta)
			if (dashLine.trailLength < 1):
				dashLine.hide()
				
		if facing == 1:
			rayW.target_position.y = 14
			rayWTwo.target_position.y = 14
			bulletRay.target_position.x = 34
		else:
			rayW.target_position.y = -14
			rayWTwo.target_position.y = -14
			bulletRay.target_position.x = -34

func _applyGravity(delta):
	if not is_on_floor():
		if (jumpNumber == 1):
			jumpNumber = 2
		if (!CharaHandler.characterData.is_empty()):
			height = CharaHandler.characterData["jump_velocity"]
		else:
			height =  40
		velocity.y += ( Conductor.physicsSpeedMultiplier * 500) * delta
	else:
		jumpNumber = 1
		
func hitStop(timeScale, duration):
	var start = Time.get_ticks_usec()
	Engine.time_scale = timeScale
	while Time.get_ticks_usec() - start < (duration/2) * 1000000:
		await get_tree().process_frame
	speedlines.hide()
	Engine.time_scale = 1

		
func _trip(delta):
	_applyGravity(delta)
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		facing = direction
	playerSprite.scale.x = facing
	
	velocity.x = facing * (sqrt(0.8 * (Conductor.physicsSpeedMultiplier*DASH_SPEED_BPM_MULTIPLIER) * maxVelocity))
	move_and_slide()
		
func _applyMovement(delta):
	if characterClass != "Gunner":
		wallJumpStuff(delta)
	if !platformBoosted:
		if (!hasWallJumped):
			var direction = Input.get_axis("left", "right")
			var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
			if (!canWallJump):
				if input_direction != 0:
					facing = sign(input_direction)
			if (!canWallJump):
				playerSprite.scale.x = facing
			if direction:
				velocity.x = direction * (sqrt(2 * (SPEED_BPM_MULTIPLIER ) * (maxWalkVelocity * Conductor.physicsSpeedMultiplier)))
			else:
				if get_tree().current_scene.name != "FROSTFALL":
					velocity.x = move_toward(velocity.x, 0, SPEED)
				else:
					var friction
					if is_on_floor():
						friction = 8
					else:
						friction = 0
					velocity.x = move_toward(velocity.x, 0, SPEED-friction)
		vertical_corner_correction(10)
	else:
		velocity.x = 0
		oldVelocity = 0
		oldVelocityVertical = 0
	move_and_slide()
	
func cameraWin():
	cam.offset.y = lerp(float(cam.offset.y), 50.0, (0.1*60)*get_physics_process_delta_time())

func wallJumpStuff(delta):
	if (hasWallJumped):
		if (wallJumpTimer > 0):
			wallJumpTimer -= (1.5*60)*delta
		else:
			hasWallJumped = false
			wallJumpTimer = 20

	if (is_on_wall()):
		for i in get_slide_collision_count():
			var collisioon = get_slide_collision(i)
			var collider = collisioon.get_collider()
			if (collider != null and collisioon.get_collider().name.begins_with("debugWallVine")):
				if Input.is_action_pressed("right"):
					if (collisioon.get_collider().side == 1):
						if stateMachine.state == stateMachine.states.dash:
							stateMachine.set_state(stateMachine.states.wallSliding)
						canWallJump = true
						diagDashDown = false
						diagDashUp = false
						dashTimeElapsed = 0.0
						has_usedDashDirChange = false
						time_remaining = 15
						facing = -1
						playerSprite.scale.x = facing
				elif Input.is_action_pressed("left"):
					if (collisioon.get_collider().side == -1):
						if stateMachine.state == stateMachine.states.dash:
							stateMachine.set_state(stateMachine.states.wallSliding)
						canWallJump = true
						diagDashDown = false
						diagDashUp = false
						dashTimeElapsed = 0.0
						has_usedDashDirChange = false
						time_remaining = 15
						facing = 1
						playerSprite.scale.x = facing
				else:
					canWallJump = false
	else:
		if (canWallJump):
			canWallJump = false

func _applyDashMovement(_delta):
	rayW.force_raycast_update()
	rayWTwo.force_raycast_update()
	vertical_corner_correction(9)
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
#						print("what the FUCK")
						position.y += 5
				else:
					if (diagDashUp):
						position.y -= 2
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
#						print("what the FUCK")
						position.y += 5
				else:
					if (diagDashUp):
						position.y -= 2
		else:
			isOnSlope = true

	timer_speed = ( Conductor.physicsSpeedMultiplier * 1.2  )
	time_remaining -= (timer_speed)
	if (time_remaining > 0):
		playerSprite.scale.x = facing
		oldVelocity = facing * (sqrt(2 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * (maxVelocity)))
		velocity.x = oldVelocity

		if (diagDashDown):
			oldVelocityVertical = (sqrt(2 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * maxVelocity*0.75))
			if (!is_on_floor()):
				velocity.y = oldVelocityVertical
			else:
				velocity.y = 0
		if (diagDashUp):
			oldVelocityVertical = (-sqrt(1.58 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * maxVelocity))
			velocity.y = oldVelocityVertical
	else:
		if (rayWThree.is_colliding() and !diagDashDown):
			groundSnap()
		var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		if input_direction != 0 and !has_usedDashDirChange and (oldVelocity > 100 or oldVelocity < -100):
			if (playerSprite.scale.x != sign(input_direction)):
				playerSprite.scale.x = sign(input_direction)
				has_usedDashDirChange = true
		dashBrake()
		if (facing != playerSprite.scale.x):
			velocity.x = -oldVelocity
		else:
			velocity.x = oldVelocity
		
		oldVelocityVertical = move_toward(oldVelocityVertical, 0,(sqrt(0.02 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * height/32)))
		if (!is_on_floor()):
			velocity.y = oldVelocityVertical
		else:
			velocity.y = 0
	corner_correction(14)
	if rayWThree.is_colliding() or is_on_floor():
		if (!isInDashAnim):
			isInDashAnim = true
			dashAnimationHandler("Dash")
	else:
		if (oldVelocityVertical > 0):
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
					dashAnimationHandler("Dash")

	move_and_slide()

func dashBrake():
	if get_tree().current_scene.name != "FROSTFALL":
		if Conductor.bpm <= 165:
			oldVelocity = move_toward(oldVelocity, 0,(sqrt(0.02 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * height/32))) 
		else:
			oldVelocity = move_toward(oldVelocity, 0,(sqrt(0.02 * (DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier) * height/32)))
	else:
		var friction
		if is_on_floor():
			friction = 0.45
		else:
			friction = 0
		oldVelocity = move_toward(oldVelocity, 0,(sqrt((1.1-friction) * ( DASH_SPEED_BPM_MULTIPLIER * Conductor.physicsSpeedMultiplier ) * height/32)))


func grounded(delta):
	_applyGravity(delta)
	if get_tree().current_scene.name != "FROSTFALL":
		velocity.x = move_toward(velocity.x, 0, SPEED/1.5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/3)
	if (groundedTime > 0):
		groundedTime -= (1*60)*delta
	move_and_slide()

func dashAnimationHandler(animName):
	var curFrame = playerSprite.get_frame()
	if (playerSprite.get_animation() != animName):
			playerSprite.play(animName)
			playerSprite.frame = curFrame

func playIdle():
#	print("???")
	if lmaoCounter < 0:
		die = true
		lmaoCounter = 0
		lmao = false
	if stateMachine.state == stateMachine.states.idle:
		playerSprite.play("Idle")
#	animPlayer.play("Idle")

func countDown():
	if Conductor.currentBeat > 1:
		countNumb += 1
	if countNumb < 4 and Conductor.currentBeat > 1:
		$CanvasLayer2/SprLevelCountdown.frame = countNumb

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

func corner_correction(amount: int):
	if velocity.y == 0:
		var delta = get_physics_process_delta_time()
		if test_move(global_transform, Vector2(velocity.x*delta,0)):
			for i in range(1,amount*2+1):
				for j in [-1.0,1.0]:
					if !test_move(global_transform.translated(Vector2(0,i*j/2)),
						Vector2(velocity.x*delta,0)):
						translate(Vector2(0,i*j/2))
						return

func vertical_corner_correction(amount: int):
	if velocity.y < 0 and stateMachine.state == stateMachine.states.jump:
		var delta = get_physics_process_delta_time()
		if test_move(global_transform, Vector2(0,velocity.y*delta)):
			for i in range(1,amount*2+1):
				for j in [-1.0,1.0]:
					if !test_move(global_transform.translated(Vector2(i*j/2,0)),
						Vector2(0,velocity.y*delta)):
						translate(Vector2(i*j/2,0))
						if velocity.x * j < 0: velocity.x = 0
						return
func spawn_dust():
	if (!punishTrip):
		var id2
		id2 = jumpDust.instantiate()
		id2.posx = position.x
		id2.posy = position.y
		id2.visible = false
		add_child(id2)
		
func parry_func(delta):
	_applyGravity(delta)
	velocity.x *= 0.85
	move_and_slide()
	
func spawn_parryFX(dir):
	velocity.x = 0
	velocity.y = 0
	oldVelocity = 0
	oldVelocityVertical = 0
	var parryId
	parryId = parryFx.instantiate()
	parryId.posx = position.x
	parryId.posy = position.y
	if dir == 1:
		parryId.posx += 28
	else:
		#print("pero eres hijo de puta?")
		parryId.posx -= 28
	parryId.top_level = true
	add_child(parryId)

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

	add_child(bulletId)
		
func deathFunc(delta):
	if (deathTimer == 20):
		dashLine.trailLength = lerp(float(dashLine.trailLength), 0.0, (0.9*60)*delta)
		Conductor.combo = 0
		deaths += 1
		deathAnim.show()
		deathAnim.frame = 0
		deathAnim.play("default")
		killSfx.play()
	if (deathTimer > 0):
		deathTimer -= (1*60)*delta

func respawnFunc():
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
	
func shake(duration: float, amplitude: float):
	var start_pos = cam.offset
	var timer = get_tree().create_timer(duration)
	while timer.time_left > 0:
		cam.offset = start_pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))
		await(get_tree().process_frame)
	cam.offset = start_pos
	
func comboMilestone():
	if (Conductor.combo > 9 and Conductor.combo <= 99):
		$CanvasLayer/Combo/ComboEffect.position.x = 76
	elif (Conductor.combo > 99 and Conductor.combo <= 999):
		$CanvasLayer/Combo/ComboEffect.position.x = 82
	elif (Conductor.combo > 999):
		$CanvasLayer/Combo/ComboEffect.position.x = 87
	else:
		$CanvasLayer/Combo/ComboEffect.position.x = 70
	$CanvasLayer/Combo/ComboEffect.frame = 0
	$CanvasLayer/Combo/ComboEffect.play("default")
	if Conductor.combo  % 30 == 0 and Conductor.combo > 1:
		var min_pitch = 0.95
		var max_pitch = 1.05
		var random_pitch = randf_range(min_pitch, max_pitch)
		$Too.play()
		$Too.pitch_scale = random_pitch
		$CanvasLayer/tooNiceAnimPlayer.play("Woaaa")
		
func _on_after_image_timer_timeout():
	if ( velocity.y > 200 or stateMachine.state == stateMachine.states.dash or platformBoosted):
		var afI = afterImage.instantiate()
		get_parent().add_child(afI)
		afI.position.x = (position.x);
		afI.position.y = position.y;
		afI.scale.x= facing
		afI.animation = playerSprite.animation
		afI.frame = playerSprite.frame
		afI.speed_scale = playerSprite.speed_scale
	else:
		var child_count = get_child_count()
		for i in range(child_count):
			var child = get_child(i)
			if child.is_in_group("afterImage"):
				child.queue_free()
func _exit_tree():
	var child_count = get_child_count()
	for i in range(child_count):
		var child = get_child(i)
		if child.is_in_group("afterImage"):
			child.queue_free()
	queue_free()

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "FadeIn" and win):
		Conductor.songUnload()
		Conductor.stopSoundEffects = false
		Conductor.stop()
		if get_tree().current_scene.name == "TUTORIAL":
			Conductor.combo = 0
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		else:
			Conductor.songToLoad(125,-1,menuSong)
			Conductor.combo = 0
			get_tree().change_scene_to_file("res://Scenes/Menus/WorldSelect.tscn")
