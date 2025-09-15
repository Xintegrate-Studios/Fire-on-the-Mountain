extends CharacterBody3D


@export_group("Utility")
@export var inventory_opened_in_air := false
@export var speed:float
@export var GAME_STATE := "NORMAL"

@export_group("Gameplay")

@export_subgroup("Health")
@export var UseHealth := true
@export var MaxHealth := 100
@export var Health := 100

@export_subgroup("Other") 
@export var Position := Vector3(0, 0, 0)

@export_group("Spawn")

@export var StartPOS := Vector3(0, 0, 0)
@export var ResetPOS := Vector3(0, 0, 0)

@export_group("Input")
@export var AllowQuitInput := true

@export_group("View Bobbing")
@export var BOB_FREQ := 3.0
@export var BOB_AMP = 0.08
@export var BOB_SMOOTHING_SPEED := 3.0

@export_subgroup("Other")
@export var Wave_Length = 0.0

@export_group("Mouse")
@export var SENSITIVITY = 0.001

@export_group("Physics")

@export_subgroup("Movement")
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export_subgroup("Crouching")
@export var CROUCH_JUMP_VELOCITY = 4.5
@export var CROUCH_SPEED := 3.0
@export var CROUCH_INTERPOLATION := 6.0
@export_subgroup("Gravity")
@export var gravity = 12.0

@export_group("Node Refs")

@export var head : Node3D
@export var camera : Camera3D
@export var task_ui_layer : CanvasLayer

@export var wood_plank_info_anim : AnimationPlayer
@export var wood_plank_info_label : Label

#region init

func start_timers():
	$Timers/SavegeryIncreaseTimer.start()
	$Timers/FireFuelDepletingTimer.start()

func _ready():
	# init bar values
	$Head/Camera3D/MainHUDLayer/SavageryBar.value = global.savagery_level
	$Head/Camera3D/MainHUDLayer/FireFuelBar.value = global.fire_fuel
	$Head/Camera3D/MainHUDLayer/ConchBar.value = global.conch_effectiveness
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # lock mouse

#endregion

#region physics

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if global.player_active:
		task_ui_layer.show()
		# Crouching
		if GAME_STATE != "DEAD" and is_on_floor():
			if Input.is_action_pressed("Crouch"):
				self.scale.y = lerp(self.scale.y, 0.5, CROUCH_INTERPOLATION * delta)
			else: 
				self.scale.y = lerp(self.scale.y, 1.0, CROUCH_INTERPOLATION * delta)
		else:
			self.scale.y = lerp(self.scale.y, 1.0, CROUCH_INTERPOLATION * delta)
		
		
		if !GAME_STATE == "DEAD":
			
			if not is_on_floor():
				velocity.y -= gravity * delta
			
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
	else:
		task_ui_layer.hide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos

#endregion

func _process(_delta: float) -> void:
	wood_plank_info_label.text = "WOOD PLANKS: " + str(global.wood_planks)

func update_bar(bar_name : String, new_value : float):
	var tween = get_tree().create_tween()
	if bar_name == "CONCH":
		tween.tween_property($Head/Camera3D/MainHUDLayer/ConchBar, "value", new_value, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	elif bar_name == "FIRE_FUEL":
		tween.tween_property($Head/Camera3D/MainHUDLayer/FireFuelBar, "value", new_value, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	elif bar_name == "SAVAGERY":
		tween.tween_property($Head/Camera3D/MainHUDLayer/SavageryBar, "value", new_value, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		print("BAR NAME NOT RECOGNISED!")

func display_task(text : String):
	$Head/Camera3D/TasksUILayer/Task.text = text
	$Head/Camera3D/TasksUILayer/TaskAnimation.play("main")


func _on_savegery_increase_timer_timeout() -> void:
	global.savagery_level += 7.0
	update_bar("SAVAGERY", global.savagery_level)

func _on_fire_fuel_depleting_timer_timeout() -> void:
	global.fire_fuel -= 7
	update_bar("FIRE_FUEL", global.fire_fuel)
