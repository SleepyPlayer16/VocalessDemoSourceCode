extends StateMachine

var cooldown = 0 # Cooldown that prevents player from spamming notes
var parryCooldown = 0 # Cooldown that prevents player from spamming parry
var beat_time = 85 # Used to calculate cooldown, name might be irrelevant
var decreaseFactor = Conductor.crotchet*1.15 # How fast cooldown goes down

var hitNote = false # Checks if player hit a note
var missedNote = false  # Checks if player missed a note

var inputs = [
	"jump", 
	"stomp", 
	"dash",
	"customAction",
	"parry",
]

@onready var judgementScene = preload("res://Scenes/FX/judgement.tscn")

func _ready():
	Conductor.noteBeatSignal.connect(_cancelDash)
	#Adds states, todo: hook state
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("trip")
	add_state("grounded")
	add_state("wakeUp")
	add_state("dash")
	add_state("wallSliding") # sliding in a walljump wall
	add_state("parry")
	add_state("stomp")
	add_state("death")
	add_state("win")
	add_state("snowBall")
	add_state("punch")
	add_state("airRollAttack")
	add_state("crouch")
	add_state("groundSlide")
	add_state("grinding")
	call_deferred("set_state", states.idle)
	decreaseFactor = Conductor.bpm * 4 #adapts to song's bpm
	if (!CharaHandler.rhythmSystemEnable):
		hitNote = true

func _process(delta):
	cooldown = max(0, cooldown - delta)
	parryCooldown = max(0, parryCooldown - delta)

func _input(event):
	#Checks for a bunch of variables before allowing the inputs to do stuff
	if !(parent.inCountdown or parent.lmao or parent.hitStopActive or parent.talking) and (event is InputEventKey):
		for action in inputs:
			if !(parent.die or parent.win or parent.talking):
				if event.is_action_pressed(action) and cooldown <= 0:
					if hitNote:
						parent.spawn_judgement(0)
						parent.inputBeat = true
						parent.metronome.play()
						Conductor.combo += 1
						parent.comboMilestone()
						if state == states.wallSliding:
							if (action == "jump"):
								jumpStuff()
							if (action == "dash"):
								if (parent.facing == -1):
									if (Input.is_action_pressed("right")):
										pass
									else:
										dashStuff()
								if (parent.facing == 1):
									if (Input.is_action_pressed("left")):
										pass
									else:
										dashStuff()
							if (action != "customAction" and CharaHandler.character != "Lane"):
								cooldown = beat_time / decreaseFactor
						if state == states.grinding:
							if (action == "jump"):
								jumpStuff()
							elif (action == "parry"):
								grindTrickStuff()
							if (action != "customAction" and CharaHandler.character != "Lane"):
								cooldown = beat_time / decreaseFactor
					else:
						if missedNote:
							offBeatHit()
							parent.spawn_judgement(1)
							parent.tripSfx.play()
					break
					
		if [states.idle, states.walk, states.grounded, states.trip, states.dash, states.stomp, states.jump, states.fall].has(state):
			if ((event.is_action_pressed("customAction") and parent.characterClass == "Gunner") and cooldown <= 0):
				cooldown = beat_time / decreaseFactor
				if hitNote:
					if (state != states.dash):
						if (state == states.grounded):
							set_state(states.idle)
						if (state == states.trip):
							set_state(states.jump)
						parent.spawn_bullet(parent.playerSprite.scale.x)
					else:
						_cancelDash()
						set_state(states.jump)
						parent.spawn_bullet(parent.playerSprite.scale.x)
				else:
					offBeatHit()
					
		if (parent.currentCharacter == "Lane"):
			if (event.is_action_pressed("customAction")) and cooldown <= 0 and parent.tripNumber < parent.maxTrips:
				cooldown = beat_time / decreaseFactor
				if hitNote:
					parent.chargeManager()
				else:
					if missedNote:
						offBeatHit()
		
		if [states.dash, states.idle, states.jump, states.fall, states.trip, states.walk].has(state):
			if (event.is_action_pressed("customAction")) and cooldown <= 0 and parent.tripNumber < parent.maxTrips:
				cooldown = beat_time / decreaseFactor
				if (parent.currentCharacter == "May"):
					if hitNote:
						if (state == states.dash):
							if (!parent.airRollAttack and !parent.is_on_floor()):
								parent.airRollHitbox.set_deferred("disabled", false)
								parent.airRollAttack = true
								parent.playerSprite.speed_scale = 5
								parent.playerSprite.play("AirRoll")
								parent.spinSfx.play()
							elif (parent.is_on_floor()):
								parent.activateDeactivateHitbox(false)
								
								set_state(states.punch)
								parent.currentPunchNumbah += 1
								if (parent.currentPunchNumbah > 1):
									parent.currentPunchNumbah = 0
						else:
							parent.activateDeactivateHitbox(false)
							set_state(states.punch)
							parent.currentPunchNumbah += 1
							if (parent.currentPunchNumbah > 1):
								parent.currentPunchNumbah = 0
					else:
						offBeatHit()
		#Checks if the player is not in any of these states before doing stuff, this code gets repeated 
		#for a bunch of states and changes depending on which state you currently are.
		if [states.idle, states.walk, states.parry, states.dash, states.stomp, states.jump, states.trip, states.fall].has(state):
			if ((event.is_action_pressed("stomp")) and cooldown <= 0 and parent.tripNumber < parent.maxTrips):
				cooldown = beat_time / decreaseFactor
				parent.velocity.x = 0
				if !(parent.rayWThree.is_colliding() or parent.is_on_floor() or parent.isOnSlope):
					if hitNote:
						resetDashStats(false)
						parent.facing = parent.playerSprite.scale.x
						if parent.velocity.y < 800:
							
							if (CharaHandler.character == "May"):
								parent.velocity.y += 300 * Conductor.singleFramephysicsSpeedMultiplier
								var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
			
								if input_direction != 0 and Input.is_action_pressed("down"):
									parent.stompDropKick = true
									parent.swing2Sfx.play()
									parent.facing = sign(input_direction)
									parent.velocity.x += (300 * parent.facing) * Conductor.singleFramephysicsSpeedMultiplier
							else:
								parent.velocity.y += 300 * Conductor.singleFramephysicsSpeedMultiplier
						set_state(states.stomp)
						hitNote = false
					else:
						offBeatHit()
			
		if [states.idle, states.grinding, states.walk, states.stomp, states.grounded, states.wakeUp, states.parry, states.wallSliding, states.dash, states.jump, states.trip, states.fall].has(state):
			if ((event.is_action_pressed("parry")) and cooldown <= 0):
				grindTrickStuff()

		if [states.grinding, states.idle, states.walk, states.stomp, states.grounded, states.wakeUp, states.parry, states.wallSliding, states.dash, states.jump, states.trip, states.fall].has(state):
			if (event.is_action_pressed("jump")) and cooldown <= 0:
				jumpStuff()
			#if (event.is_action_pressed("jump_ctr")) and cooldown <= 0:
				#jumpStuff()
		if [states.idle, states.stomp ,states.walk, states.grounded, states.parry, states.wakeUp, states.dash, states.jump, states.trip, states.fall].has(state):
			if (event.is_action_pressed("dash")) and cooldown <= 0:
				cooldown = beat_time / decreaseFactor
				if (hitNote):
					dashStuff()
				else:
					offBeatHit()
	if (!CharaHandler.rhythmSystemEnable):
		hitNote = true

func verticalDashDirectionStuff(vInput_direction): # If player did a diagonal dash, then handle diag dash stuff
	if vInput_direction == -1:
		if parent.diagDashNumber < parent.diagDashMaxNumber:
			#I'll clean this shit later
			if (CharaHandler.character != "May"):
				if !parent.is_on_floor():
					parent.diagDashNumber += 1
				parent.diagDashUp = true
				resetDashStats(true)
				switchToDash()
			else:
				resetDashStats(true)
				switchToDash() 
				if !parent.is_on_floor():
					parent.diagDashNumber += 1
				parent.diagDashUp = true
	else:
		parent.diagDashDown = true
		resetDashStats(true)
		switchToDash()

func dashStuff():
	parent.facing = parent.playerSprite.scale.x
	parent.isOnSlope = false
	if parent.last_animation == "Dash":
		parent.last_animation = "Dash_Air"
	else:
		parent.last_animation = "Dash"
	if parent.tripNumber < parent.maxTrips:
		parent.diagDashUp = false
		parent.diagDashDown = false
		var input_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		var vInput_direction = Input.get_action_strength("down") - Input.get_action_strength("up")
		if input_direction != 0:
			if parent.dashNumber < parent.dashMaxNumber:
				parent.facing = sign(input_direction)
				parent.playerSprite.scale.x = parent.facing
				parent.playerSprite.scale.x = parent.facing
		#if parent.currentCharacter != "May":
		if vInput_direction != 0:
			verticalDashDirectionStuff(vInput_direction)
		#else:
		#if parent.currentCharacter != "May":
			#if vInput_direction == -1:
				#if parent.diagDashNumber < parent.diagDashMaxNumber:
					#if !parent.is_on_floor():
						#parent.diagDashNumber += 1

		if parent.dashNumber < parent.dashMaxNumber:
			if !parent.diagDashUp:
				if !parent.is_on_floor():
					parent.dashNumber += 1
				resetDashStats(true)
				switchToDash()
		hitNote = false

func grindTrickStuff():
	#if parent.currentCharacter != "May":
	if (hitNote):
		parent.spawn_judgement(0)
		parent.inputBeat = true
		Conductor.combo += 1
		parent.comboMilestone()
		cooldown = beat_time / decreaseFactor
		parent.metronome.play()
		hitNote = false
		if (state == states.grinding):
			#print("uhdjka")
			parent.playerSprite.scale.x = 1.5*parent.facing
			parent.playerSprite.scale.y = 0.8
			parent.parriedEnemy(true)
			if (parent.limitArea != null):
				if (parent.limitArea.tricks < parent.limitArea.trickLimit):
					parent.limitArea.tricks += 1
					if (CharaHandler.idealParries != parent.parries):
						parent.parries += 1
						parent.createParryText("+1 trick!")
			parent.playerSprite.play("Trick"+str(parent.trickRotation))
			parent.trickRotation += 1
			if (parent.trickRotation > 3):
				parent.trickRotation = 1
	else:
		if (Conductor.playing):
			offBeatHit()
			parent.spawn_judgement(1)
			parent.tripSfx.play()
	#else:
		#if (hitNote):
			#parent.metronome.play()
			#hitNote = false
		#else:
			#offBeatHit()
			#parent.spawn_judgement(1)
			#parent.tripSfx.play()

func jumpStuff():
	cooldown = beat_time / decreaseFactor
	if (hitNote):
		#parent.oldVelocityVertical = 0
		if (state == states.wallSliding):
			parent.wallJumpTimerDecreaseRate = 75.0
			parent.velocity.x = parent.facing * ((2.1 * 90))
			if (CharaHandler.character != "Lane"):
				parent.velocity.y = -(parent.jumpsp * Conductor.singleFramephysicsSpeedMultiplier)
			else:
				parent.velocity.y = 0
				parent.velocity.y = -(parent.jumpsp * Conductor.singleFramephysicsSpeedMultiplier)
			parent.velocity.x *= Conductor.singleFramephysicsSpeedMultiplier
			parent.jumpSfx.play()
			if (CharaHandler.character == "May"):
				parent.swing1Sfx.play()
			parent.wallJumpTimer = parent.wallJumpTime
			parent.hasWallJumped = true

		if (parent.is_on_floor()):
			if parent.jumpNumber != 1:
				parent.jumpNumber = 1
			if (CharaHandler.effectsEnabled):
				parent.spawn_dust(0)
		if ((parent.jumpNumber < parent.maxJumps) and (parent.tripNumber < parent.maxTrips)):
			parent.jumpSfx.play()
			if (parent.currentActionBoost != 0.0):
				parent.phantomDashSfx.play()
			parent.facing = parent.playerSprite.scale.x
			if (state != states.wallSliding):
				parent.jumpNumber += 1
			resetDashStats(false)
			if parent.jumpBoostPawaaaa != 0 and parent.is_on_floor():
				parent.platformBoosted = true
				parent.speedLineTimer.start()
				#parent.velocity.y = 0
				parent.boostedJumpSfx.play()
				parent.speedlines.show()
				parent.cam.zoom.x = 3.35
				parent.cam.zoom.y = 3.35

			else:
				parent.platformBoosted = false
				parent.boostedJunmpParticles.emitting = false
			if parent.jumpNumber < parent.maxJumps or (parent.currentCharacter == "Nix" or parent.currentCharacter == "May"):
				parent.velocity.y = -((parent.jumpsp + parent.currentActionBoost) * Conductor.singleFramephysicsSpeedMultiplier)
				parent.deactivateCharge()
			if parent.jumpNumber == parent.maxJumps and (parent.currentCharacter != "Nix" or parent.currentCharacter == "May"):
				parent.velocity.y = -((parent.jumpsp  + parent.currentActionBoost) / 1.2 * Conductor.singleFramephysicsSpeedMultiplier)
				parent.deactivateCharge()
			set_state(states.jump)
			hitNote = false
	else:
		offBeatHit()

func switchToDash(): # Stuff that happens after pressing the Dash Input to the beat
	var min_pitch = 0.95
	var max_pitch = 1.05
	var random_pitch = randf_range(min_pitch, max_pitch)
	
	parent.dashSfx.pitch_scale = random_pitch
	parent.dashSnapTimer = 0.5
	call_deferred("set_state", states.dash)
	parent.oldVelocityVertical = 0
	parent.velocity.y = 0
	parent.dashSfx.play()
	if (parent.currentActionBoost != 0.0):
		parent.phantomDashSfx.play()
	if (parent.canPhantomDash and !parent.phantomDashOnCoolDown):
		parent.phantomDashSfx.play()
		parent.phantomTime = 4
		parent.phantomDashOnCoolDown = true
		parent.oldVelocity = parent.playerSprite.scale.x * (((6 + (parent.currentActionBoost)) + parent.dashSpeed * 53) * Conductor.singleFramephysicsSpeedMultiplier)
	else:
		if parent.currentCharacter == "May":
			if (Input.is_action_pressed("up") and (parent.diagDashNumber != parent.diagDashMaxNumber)):
				parent.oldVelocityVertical = -286 * Conductor.singleFramephysicsSpeedMultiplier
			elif (Input.is_action_pressed("down")):
				parent.oldVelocityVertical = 250 * Conductor.singleFramephysicsSpeedMultiplier
			else:
				parent.oldVelocityVertical = -146 * Conductor.singleFramephysicsSpeedMultiplier
		parent.oldVelocity = parent.playerSprite.scale.x * ((6 + (parent.dashSpeed + (parent.currentActionBoost / 25)) * 53) * Conductor.singleFramephysicsSpeedMultiplier)
	parent.velocity.x *= Conductor.singleFramephysicsSpeedMultiplier
	#if parent.currentCharacter == "May":
		#parent.velocity.y *= Conductor.singleFramephysicsSpeedMultiplier
	if parent.currentCharacter != "May":
		if (parent.diagDashDown):
			parent.oldVelocityVertical =  (((8 + (parent.dashSpeed + (parent.currentActionBoost / 30)) * 40) * Conductor.singleFramephysicsSpeedMultiplier))
	
		if (parent.diagDashUp):
			parent.oldVelocityVertical =  -((6.5 + (parent.dashSpeed + (parent.currentActionBoost / 30)) * 40) * Conductor.singleFramephysicsSpeedMultiplier)
	
		parent.velocity.y *= Conductor.singleFramephysicsSpeedMultiplier
	await get_tree().create_timer(0.1).timeout
	parent.deactivateCharge()
	#else:
		#parent.running = true

func _state_logic(delta):
	#First we check for variables that shouldn't let the player move
	if (parent.playerSprite != null):
		if !(parent.inCountdown and !parent.hitStopActive):
			if !(parent.die or parent.win or parent.inSnowBall or parent.talking):
				if (parent.rayWThree.is_colliding() or parent.is_on_floor() or parent.isOnSlope):
					if !parent.punishTrip:
						parent.tripNumber = 0
						parent.fallThroughRail = false
					if !parent.diagDashUp:
						parent.jumpNumber = 1
						parent.diagDashNumber = 1
						parent.dashNumber = 1

				if ![states.grinding, states.dash, states.parry, states.trip, states.grounded, states.punch].has(state): #Checks if the player is not in any of these states before doing stuff
					parent.playerSprite.speed_scale = 2
					if parent.currentCharacter == "May":
						parent.airRollAttack = false
						parent.airRollHitbox.set_deferred("disabled", true)
						parent.puncHitbox.set_deferred("disabled", true)
						parent.playerSprite.offset.y = -4
					parent.has_usedDashDirChange = false
					parent.has_usedVerticalDashDirChange = false
					parent.isInDashAnim = false
					parent.time_remaining = 15.0 / Conductor.singleFramephysicsSpeedMultiplier
					parent._applyMovement(delta)
					parent._applyGravity()
					
					parent.isOnSlope = false
				if (state == states.dash):
					parent.tripTime = 25
					parent.newDashMovement(delta)
				if !(state == states.grinding):
					if (parent.railSfx.playing):
						parent.railSfx.stop()
					if (parent.playerSprite.rotation_degrees != 0):
						parent.playerSprite.rotation_degrees = 0
						if (CharaHandler.character != "Lane"):
							parent.playerSprite.offset.y = 0
							parent.playerSprite.offset.x = 0
						else:
							parent.playerSprite.offset.y = -4
							parent.playerSprite.offset.x = 0
				if (state == states.trip):
					parent.airRollAttack = false
					parent.airRollHitbox.set_deferred("disabled", true)
					parent.puncHitbox.set_deferred("disabled", true)
					parent.isOnSlope = false
					parent.isInDashAnim = false
					parent._trip(delta)
			else:
				if (parent.die):
					set_state(states.death)
					parent.deathFunc(delta)
				elif (parent.win):
					if (!Conductor.stopSoundEffects):
						Conductor.stopSoundEffects = true
					set_state(states.win)
					parent.cameraWin()
				elif (parent.inSnowBall):
					set_state(states.snowBall)
	
func resetDashStats(usedWithingDash): # Resets dash stuff either after cancelling with another dash or after doing something else
	if !usedWithingDash:
		parent.diagDashUp = false
		parent.diagDashDown = false
	parent.airRollAttack = false
	parent.stompDropKick = false
	parent.has_usedDashDirChange = false
	parent.has_usedVerticalDashDirChange = false
	parent.time_remaining = 15.0 / Conductor.singleFramephysicsSpeedMultiplier

func _get_transition(delta): # Does stuff depending on player's current state
	match (state):
		states.idle:
			parent.tripNumber = 0
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0 and !parent.is_on_wall():
				return states.walk
		states.walk:
			parent.playerSprite.speed_scale = 1.3 * (Conductor.physicsSpeedMultiplier)
			if (!parent.is_on_wall()):
				parent.corner_correction(16)
			parent.tripNumber = 0
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0 or parent.is_on_wall():
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent.canWallJump:
				return states.wallSliding
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
			elif parent.canWallJump:
				return states.wallSliding
			parent.grindRay.force_raycast_update()
			if (!parent.fallThroughRail):
				if parent.grindRay.is_colliding() and !(Input.is_action_pressed("down")):
					#print(parent.grindRay.get_collider().rotation_degrees)
					if (parent.grindRay.get_collider().name.begins_with("GrindZone")):
						#print("kjdfla")
						if (parent.grindRay.get_collider().rotation_degrees >= 44):
							parent.position.y = parent.grindRay.get_collision_point().y-17
							if (parent.facing == 1):
								parent.velocity.y = (parent.maxWalkVelocity*75)
							else:
								parent.velocity.y = -(parent.maxWalkVelocity*115)
						else:
							parent.velocity.y = 0
							parent.position.y = parent.grindRay.get_collider().position.y-17
						parent.railHopOnSfx.play()
						return states.grinding
		states.trip:
			
			if !parent.hitStopActive:
				parent.playerSprite.speed_scale = 1.5 * Conductor.physicsSpeedMultiplier
			else:
				parent.playerSprite.speed_scale = 0
			if parent.tripNumber >= parent.maxTrips:
				if (!parent.punishTrip):
					parent.punishTrip = true
					parent.timeElapsedManager(false)
					Conductor.combo = 0
			if parent.is_on_floor():
				if (!parent.punishTrip):
					parent.tripNumber = 0
				parent.groundedTime = 30
				return states.grounded
		states.grounded:
			parent.grounded(get_physics_process_delta_time())
			if parent.is_on_floor():
				if !parent.playerSprite.animation == "Grounded":
					parent.playerSprite.play("Grounded")
				if parent.groundedTime <= 0:
					parent.tripNumber = 0
					parent.punishTrip = false
					return states.idle
			else:
				parent.groundedTime = 30
				if !parent.playerSprite.animation == "Trip":
					parent.playerSprite.play("Trip")
		states.wallSliding:
			resetDashStats(false)
			if (CharaHandler.character != "Lane"):
				if (parent.velocity.y >= 0):
					parent.velocity.y = lerp(parent.velocity.y, 20.0 * Conductor.physicsSpeedMultiplier, (0.2 * 60) * delta)
			else:
				parent.velocity.y = -180.0 * Conductor.physicsSpeedMultiplier
			
			if (Input.is_action_just_pressed("left") and parent.facing == -1):
				parent.hasWallJumped = false
				parent.wallJumpTimer = 0
			elif (Input.is_action_just_pressed("right") and parent.facing == 1):
				parent.hasWallJumped = false
				parent.wallJumpTimer = 0

			if !parent.canWallJump:
				return states.fall
		states.death:
			if parent.deathTimer <= 0:
				parent.respawnFunc()
				return states.idle
		states.parry:
			parent.parry_func(delta)
			if (!parent.hitStopActive):
				parent.playerSprite.speed_scale = 3
			else:
				parent.playerSprite.speed_scale = 0
			if (!parent.playerSprite.is_playing()):
				if parent.is_on_floor():
					return states.idle
				else:
					return states.fall
		states.stomp:
			if parent.is_on_floor():
				parent.stompDropKick = false
				parent.shake(0.2, 1)
				parent.velocity.x = 0
				return states.idle
			parent.grindRay.force_raycast_update()
			if (!parent.fallThroughRail):
				if parent.grindRay.is_colliding() and !(Input.is_action_pressed("down")):
					#print(parent.grindRay.get_collider().rotation_degrees)
					if (parent.grindRay.get_collider().name.begins_with("GrindZone")):
						#print("kjdfla")
						if (parent.grindRay.get_collider().rotation_degrees >= 44):
							parent.position.y = parent.grindRay.get_collision_point().y-17
							if (parent.facing == 1):
								parent.velocity.y = (parent.maxWalkVelocity*45)
							else:
								parent.velocity.y = -(parent.maxWalkVelocity*75)
						else:
							parent.velocity.y = 0
							parent.position.y = parent.grindRay.get_collider().position.y-17
						parent.railHopOnSfx.play()	
						return states.grinding
		states.dash:
			#if parent.canWallJump and parent.playerSprite.frame > 4:
				#return states.wallSliding
			if (parent.characterClass != "Gunner"):
				parent.wallJumpStuff(delta)
			if (parent.is_on_floor() and parent.currentCharacter == "Froo"):
				if (!parent.is_on_wall()):
					if (parent.playerSprite.scale.x == 1):
						if (parent.velocity.x < 0.05):
							parent.playerSprite.play("Stare")
					elif (parent.playerSprite.scale.x == -1):
						if (parent.velocity.x > -0.05):
							parent.playerSprite.play("Stare")
			if (parent.is_on_floor() and parent.currentCharacter == "May"):
				if (parent.playerSprite.get_animation() != "Roll"):
					parent.velocity.y = 0
					parent.oldVelocity += (200 * parent.facing) * Conductor.singleFramephysicsSpeedMultiplier
					parent.oldVelocityVertical = 0
					parent.groundSnap()
					parent.playerSprite.play("Roll")
					parent.airRollHitbox.set_deferred("disabled", true)
				if (parent.playerSprite.get_animation() == "Roll" and parent.playerSprite.frame > 1):
					parent.playerSprite.offset.y = -4
				var beats_per_second = Conductor.bpm / 60.0
				var seconds_per_beat = 0.7 / beats_per_second
				var curAnim = parent.playerSprite.get_animation()
				var animation_length = parent.playerSprite.sprite_frames.get_frame_count(curAnim) / (parent.playerSprite.sprite_frames.get_animation_speed("Dash") * seconds_per_beat)
				if (CharaHandler.character != "Lane"):
					parent.playerSprite.speed_scale = animation_length * Conductor.singleFramephysicsSpeedMultiplier
				else:
					parent.playerSprite.speed_scale = (animation_length / 4) * Conductor.singleFramephysicsSpeedMultiplier
		states.snowBall:
			parent.playerSprite.visible = false
		states.punch:
			parent.move_and_slide()
			parent._applyGravity()
			var spd = Conductor.singleFramephysicsSpeedMultiplier / 17.0
			parent.velocity.x = lerpf(parent.velocity.x, 0.0, (spd * 60) * delta)
			parent.playerSprite.offset.y = -4
			var beats_per_second = Conductor.bpm / 60.0
			var seconds_per_beat = 0.7 / beats_per_second
			var curAnim = parent.playerSprite.get_animation()
			var animation_length = parent.playerSprite.sprite_frames.get_frame_count(curAnim) / (parent.playerSprite.sprite_frames.get_animation_speed("Dash") * seconds_per_beat)
			parent.playerSprite.speed_scale = animation_length / 1.2 * Conductor.singleFramephysicsSpeedMultiplier
			if (parent.playerSprite.frame >= 4):
				parent.activateDeactivateHitbox(true)
				if !parent.is_on_floor():
					if parent.velocity.y < 0:
						return states.jump
					elif parent.velocity.y >= 0:
						return states.fall
				if parent.velocity.x == 0:
					return states.idle
				else:
					return states.walk
		states.grinding:
			if (parent.tripNumber != 0):
				parent.tripNumber = 0
			if (!parent.fallThroughRail):
				if parent.is_on_wall():
					parent.facing *= -1
					parent.playerSprite.scale.x = parent.facing
				parent.wasGrindin = true
				parent.jumpNumber = 1
				if (!parent.railSfx.playing):
					parent.railSfx.play()

				if !parent.grindRay.is_colliding():
					return states.fall
				parent.grindRay.force_raycast_update()
				if parent.grindRay.is_colliding():
					if !(Input.is_action_pressed("down")):
						if (parent.grindRay.get_collider().name.begins_with("GrindZone")):
							if (parent.grindRay.get_collider().rotation_degrees >= 44):
								parent.position.y = parent.grindRay.get_collision_point().y-17
								if (parent.facing == 1):
									parent.velocity.y = ((2.0*Conductor.singleFramephysicsSpeedMultiplier))/2.0
								else:
									parent.velocity.y = -((2.0*Conductor.singleFramephysicsSpeedMultiplier)*100)*2.0
								var rotDeg = parent.playerSprite.rotation_degrees
								parent.playerSprite.rotation_degrees = lerp(rotDeg, 45.0, (0.3*60)*get_physics_process_delta_time())
								if (parent.facing == 1):
									if (CharaHandler.character != "Lane"):
										parent.playerSprite.offset.y = -4
									else:
										parent.playerSprite.offset.y = -8
								else:
									if (CharaHandler.character != "Lane"):
										parent.playerSprite.offset.y = -2
									else:
										parent.playerSprite.offset.y = -7
								parent.playerSprite.offset.x = lerp(parent.playerSprite.offset.x, (2.0*parent.facing), (0.1*60)*get_physics_process_delta_time())
							else:
								var rotDeg = parent.playerSprite.rotation_degrees
								parent.playerSprite.rotation_degrees = lerp(rotDeg, 0.0, (0.3*60)*get_physics_process_delta_time())
								if (CharaHandler.character != "Lane"):
									parent.playerSprite.offset.y = 0
								else:
									parent.playerSprite.offset.y = -4
								parent.playerSprite.offset.x = lerp(parent.playerSprite.offset.x, 0.0, (0.1*60)*get_physics_process_delta_time())
								parent.position.y = parent.grindRay.get_collider().position.y-17
								parent.velocity.y = 0
							parent.velocity.x = ((2.0*Conductor.singleFramephysicsSpeedMultiplier)*75)*parent.facing
							parent.move_and_slide()
							if (state != states.grinding):
								return states.grinding
					else:
						if parent.wasGrindin:
							parent.fallThroughRail = true
							parent.wasGrindin = false
							parent.velocity.y = 0
						return states.fall
			if (parent.fallThroughRail):
				parent.wasGrindin = false
				parent.velocity.y = 0
				return states.fall
	return null

func _enter_state(new_state, _old_state): #Does something for 1 frame right before entering a state
	if (parent.playerSprite != null):
		match (new_state):
			states.idle:
				parent.playerSprite.play("Idle")
				parent.playerSprite.frame = 4
			states.walk:
				parent.playerSprite.play("Walk")
			states.dash:
				parent.fallThroughRail = false
				parent.wasGrindin = false
				parent.has_dashed = true
				parent.isInDashAnim = false
				parent.playerSprite.frame = 0
				if (parent.diagDashDown and !parent.rayWThree.is_colliding()):
					parent.playerSprite.play("Dash_Down")
				elif (parent.diagDashUp):
					parent.playerSprite.play("Dash_Up")
				else:
					parent.playerSprite.play("Dash")
				var beats_per_second = Conductor.bpm / 60.0
				var seconds_per_beat = 0.7 / beats_per_second
				var curAnim = parent.playerSprite.get_animation()
				var animation_length = parent.playerSprite.sprite_frames.get_frame_count(curAnim) / (parent.playerSprite.sprite_frames.get_animation_speed("Dash") * seconds_per_beat)
				if (CharaHandler.character != "Lane"):
					parent.playerSprite.speed_scale = animation_length * Conductor.singleFramephysicsSpeedMultiplier
				else:
					parent.playerSprite.speed_scale = (animation_length * 0.6) * Conductor.singleFramephysicsSpeedMultiplier
			states.jump:
				parent.playerSprite.play("Jump")
				if (!parent.is_on_floor() and CharaHandler.character == "Lane"):
					parent.playerSprite.frame = 1
				parent.fallThroughRail = false
			states.fall:
				parent.playerSprite.play("Fall")
			states.trip:
				parent.fallThroughRail = false
				parent.wasGrindin = false
				parent.stompDropKick = false
				parent.playerSprite.speed_scale = 2
				parent.tripTime = 25
				var vInput_direction = Input.get_action_strength("down") - Input.get_action_strength("up")

				if vInput_direction == 1:
					parent.oldVelocityVertical = (250 / 1.1) * Conductor.singleFramephysicsSpeedMultiplier
				elif (vInput_direction == -1 or vInput_direction == 0):
					parent.oldVelocityVertical = -(295 / 1.3) * Conductor.singleFramephysicsSpeedMultiplier

				if parent.jumpBoostPawaaaa != 0:
					parent.lmao = true
				parent.velocity.y = parent.oldVelocityVertical

				parent.playerSprite.play("Trip")
			states.grounded:
				parent.playerSprite.play("Grounded")
				parent.diagDashDown = false
				parent.diagDashUp = false
			states.wallSliding:
				parent.playerSprite.play("WallStuck")
			states.death:
				parent.playerSprite.hide()
			states.parry:
				if parent.currentCharacter == "May":
					parent.airRollAttack = false
					parent.playerSprite.offset.y = -4
				parent.playerSprite.speed_scale = 3
				parent.playerSprite.frame = 0
				parent.playerSprite.play("Parry")
			states.stomp:
				if parent.stompDropKick:
					parent.playerSprite.play("DropKick")
				else:
					parent.playerSprite.play("Stomp")
			states.win: 
				parent.playerSprite.play("Win")
			states.punch:
				if (parent.currentPunchNumbah == 0):
					parent.swing1Sfx.play()
				else:
					parent.swing2Sfx.play()
				parent.playerSprite.play("Punch_" + str(parent.currentPunchNumbah))
			states.grinding:
				parent.playerSprite.play("Grinding")

func _cancelDash(): #Cancels dash, either after it has ran out or after cancelling it with another dash
	if (state == states.dash):
		if (!parent.has_dashed) and (abs(parent.oldVelocity) < Conductor.singleFramephysicsSpeedMultiplier * 30):
			dashCancelProps()

func dashCancelProps():
	if (parent.currentCharacter == "May"):
		parent.airRollAttack = false
		parent.playerSprite.offset.y = -4
	parent.airRollHitbox.set_deferred("disabled", true)
	parent.stompDropKick = false
	parent.facing = parent.playerSprite.scale.x
	parent.diagDashUp = false
	parent.diagDashDown = false
	if (parent.rayWThree.is_colliding() or parent.is_on_floor() or parent.isOnSlope):
		call_deferred("set_state", states.idle)
	else:
		call_deferred("set_state", states.fall)
	if (parent.velocity.y >= 0 and parent.currentCharacter != "May"):
		#print("dsk")
		parent.facing = parent.playerSprite.scale.x
		parent.diagDashUp = false
		parent.diagDashDown = false
		call_deferred("set_state", states.fall)

#func spawn_judgement(judgement): # Spawns a judgement (Cool and Oops sprites)
	#if (CharaHandler.beatHitsEnabled):
		#parent.spawn_judgement(judgement)
	
func GoodToGo(): # Checks if player hit a note
	missedNote = false
	hitNote = true
	

func youFool(): # Checks if player missed a note
	#print("what the fuck")
	hitNote = false
	missedNote = true

func offBeatHit(): # Activates trip after missing a note
	if missedNote:
		cooldown = beat_time / decreaseFactor
		if parent.tripNumber < parent.maxTrips:
			parent.platformBoosted = false
			parent.boostedJunmpParticles.emitting = false
			parent.tripNumber += 1
	#		print("uuadfjfg")
			parent.facing = parent.playerSprite.scale.x
			set_state(states.trip)
			parent.tripTime = 25
	missedNote = false
