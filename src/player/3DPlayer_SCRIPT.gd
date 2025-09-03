extends CharacterBody3D # Inheritance


# Utility variables
@export_group("Utility") ## A group for gameplay variables
@export var inventory_opened_in_air := false ## Checks if the inventory UI is opened in the air (so the same velocity can be kept, used in _physics_process()
@export var speed:float ## The speed of the player. Used in _physics_process, this variable changes to SPRINT_SPEED, CROUCH_SPEED or WALK_SPEED depending on what input is pressed.
@export var GAME_STATE := "NORMAL" ## The local game state. (Global variable is in PlayerData.gd and saved to a file)

@export_group("Gameplay") ## A group for gameplay variables

@export_subgroup("Health") ## Health varibales subgroup 
@export var UseHealth := true ## Checks if health should be used. If false no health label/bar will be displayed and the player won't be able to die/take damage)
@export var MaxHealth := 100 ## After death or when the game is first opened, the Health variable is set to this. 
@export var Health := 100 ## The player's health. If this reaches 0, the player dies.

@export_subgroup("Other") 
@export var Position := Vector3(0, 0, 0) ## What the live position for the player is. This no longer does anything if changed in the inspector panel.

@export_group("Spawn") ## A group for spawn variables

@export var StartPOS := Vector3(0, 0, 0) ## This no longer does anything if changed because this is always set to the value from the save file.
@export var ResetPOS := Vector3(0, 0, 0) ## Where the player goes if the Reset input is pressed. 999, 999, 999 for same as StartPOS. 

@export_subgroup("Fade_In") ## A subgroup for the fade-in variables (on spawn)
@export var Fade_In := false ## Whether to use the fade-in on startup or not. Reccomended to keep this on because it looks cool. 
@export var Fade_In_Time := 1.000 ## The time it takes for the overlay to reach Color(0, 0, 0, 0) in seconds. 

@export_group("Input") ## A group relating to inputs (keys on your keyboard)
@export var Pause := true  ## Whether or not the player can use the Pause input to pause the game. (Normally Esc) (will be ON for final game.)
@export var Reset := true ## Whether or not the player can use the Reset input to reset the player's position (Normally Ctrl+R) (will be OFF for final game.)
@export var Quit := true ## Whether or not the player can use the Quit input to quit the game (Normally Ctrl+Shift+Q) (will be OFF for final game.)


@export_group("Visual") ## A group for visual/camera variables
@export_subgroup("Camera")
@export var FOV = 120
@export_subgroup("Crosshair") ## A subgroup for crosshair variables.
@export var crosshair_size = Vector2(12, 12) ## The size of the crosshair.

@export_group("View Bobbing") ## a group for view bobbing variables.


@export var BOB_FREQ := 3.0 ## The frequency of the waves (how often it occurs)
@export var BOB_AMP = 0.08 ## The amplitude of the waves (how much you actually go up and down)
@export var BOB_SMOOTHING_SPEED := 3.0  ## Speed to smooth the return to the original position. The lower it get's, the smoother it is.

@export_subgroup("Other") ## a subgroup for other view bobbing variables.
@export var Wave_Length = 0.0 ## The wavelength of the bobbing

@export_group("Mouse") ## A group for mouse variables.
@export var SENSITIVITY = 0.001 ## The sensitivity of the mouse when it is locked in the center (during gameplay)

@export_group("Physics") ## A group for physics variables.

@export_subgroup("Movement") ## A subgroup for movement variables.
@export var WALK_SPEED = 5.0 ## The normal speed at which the player moves.
@export var SPRINT_SPEED = 8.0 ## The speed of the player when the user is pressing/holding the Sprint input.
@export var JUMP_VELOCITY = 4.5 ## How much velocity the player has when jumping. The more this value is, the higher the player can jump.
@export_subgroup("Crouching") ## A subgroup for crouching variables.
@export var CROUCH_JUMP_VELOCITY = 4.5 ## How much velocity the player has when jumping. The more this value is, the higher the player can jump.
@export var CROUCH_SPEED := 3.0 ## The speed of the player when the user is pressing/holding the Crouch input.
@export var CROUCH_INTERPOLATION := 6.0 ## How long it takes to go to the crouching stance or return to normal stance.
@export_subgroup("Gravity") ## A subgroup for gravity variables.
@export var gravity = 12.0 ## Was originally 9.8 (Earth's gravitational pull) but I felt it to be too unrealistic. This is the gravity of the player. The higher this value is, the faster the player falls.

# Body parts variables
@onready var head = $Head # reference to the head of the player scene. (used for mouse movement and looking around)
@onready var camera = $Head/Camera3D # reference to the camera of the player (used for mouse movement and looking around)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
func _input(_event): # A built-in function that listens for input using the input map
	if Input.is_action_just_pressed("Quit") and Quit == true:
		get_tree().quit() # quit
	if Input.is_action_just_pressed("Reset") and Reset == true:
		if ResetPOS == Vector3(999, 999, 999):
			self.position = StartPOS
		else:
			self.position = ResetPOS

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


# Modify _physics_process to include smooth transition when not moving
func _physics_process(delta): # This is a special function that is called every frame. It is used for physics calculations. For example, if I run the game on a computer that has a higher/lower frame rate, the physics will still be consistent.
	
	# Crouching
	if GAME_STATE != "DEAD" and is_on_floor(): # Check if the game state is not inventory or dead and if the player is on the floor
		if Input.is_action_pressed("Crouch"): # Check if the Crouch input is pressed
			self.scale.y = lerp(self.scale.y, 0.5, CROUCH_INTERPOLATION * delta) # linearly interpolate the scale of the player on the y-axis to 0.5
		else: 
			self.scale.y = lerp(self.scale.y, 1.0, CROUCH_INTERPOLATION * delta) # linearly interpolate the scale of the player on the y-axis to 1.0
	else:
		self.scale.y = lerp(self.scale.y, 1.0, CROUCH_INTERPOLATION * delta) # linearly interpolate the scale of the player on the y-axis to 1.0
	
	
	if !GAME_STATE == "DEAD":
		# Always apply gravity unless game state is DEAD
		if not is_on_floor(): # Check if the player is not on the floor
			velocity.y -= gravity * delta # apply gravity to the player


		# Jumping
		if Input.is_action_just_pressed("Jump") and is_on_floor() and !Input.is_action_pressed("Crouch"): # Check if the Jump input is pressed, the player is on the floor and the Crouch input is not pressed
			velocity.y = JUMP_VELOCITY # set the player's velocity to the jump velocity

		# Handle Speed
		if Input.is_action_pressed("Sprint") and !Input.is_action_pressed("Crouch"): # Check if the Sprint input is pressed and the Crouch input is not pressed
			speed = SPRINT_SPEED # set the speed to the sprint speed
		elif Input.is_action_pressed("Crouch"): # Check if the Crouch input is pressed
			speed = CROUCH_SPEED # set the speed to the crouch speed
		else: 
			speed = WALK_SPEED # set the speed to the walk speed
		

		# Movement
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward") # get the input direction
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # get the direction of the player

		if is_on_floor(): # Check if the player is on the floor
			if direction != Vector3.ZERO: # Check if the direction is not zero
				velocity.x = direction.x * speed # set the player's velocity on the x-axis to the direction times the speed
				velocity.z = direction.z * speed # set the player's velocity on the z-axis to the direction times the speed
			else:
				velocity.x = lerp(velocity.x, 0.0, delta * 10.0) # linearly interpolate the player's velocity on the x-axis to 0
				velocity.z = lerp(velocity.z, 0.0, delta * 10.0) # linearly interpolate the player's velocity on the z-axis to 0
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0) # linearly interpolate the player's velocity on the x-axis to the direction times the speed
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0) # linearly interpolate the player's velocity on the z-axis to the direction times the speed

		
		move_and_slide() # Apply gravity and handle movement

		# Check if the player is moving and on the floor
		var is_moving = velocity.length() > 0.1 and is_on_floor()

		# Apply view bobbing only if the player is moving
		if is_moving:
			Wave_Length += delta * velocity.length() # Increase the wave length based on the player's velocity
			camera.transform.origin = _headbob(Wave_Length) # Apply the headbob function to the camera's origin
		else:
			# Smoothly return to original position when not moving
			var target_pos = Vector3(camera.transform.origin.x, 0, camera.transform.origin.z) # get the target position
			camera.transform.origin = camera.transform.origin.lerp(target_pos, delta * BOB_SMOOTHING_SPEED) # linearly interpolate the camera's origin to the target position

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos


func _ready(): # called when node enters scene tree, i.e when it has fully loaded
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # lock mouse
