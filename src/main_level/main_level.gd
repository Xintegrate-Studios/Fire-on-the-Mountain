extends Node3D

#region exports and variables

var default_conch_transform

# Characters
@export var Character_1 : Node3D
@export var Character_2 : Node3D
@export var Character_3 : Node3D
@export var Character_4 : Node3D
@export var Character_5 : Node3D
@export var Character_6 : Node3D
@export var Character_7 : Node3D
@export var Character_8 : Node3D
@export var Character_9 : Node3D
@export var Character_10 : Node3D

# Environment
@export var firepit_tinder : Node3D
@export var HideCharactersList : Array[Node3D]

#endregion


#region ready
func _ready() -> void:
	default_conch_transform = $conch.transform
	
	# Setup globals
	global.world = self
	global.player = $"Player"
	global.pause_animation_player = $Camera3D/PauseAnimation
	global.player_active = false
	
	# Initial UI / input
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"Player/Head/Camera3D/MainHUDLayer".hide()
	
	# Fade and menu intro
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
	await get_tree().create_timer(0.5).timeout
	$Camera3D/MenuAnimation.play("main")
#endregion

#region input
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Tutorial"):
		pass
	
	if Input.is_action_just_pressed("Interact") \
	and global.is_in_climb_mountain_area \
	and !global.is_on_top_of_mountain:
		go_to_top_of_mountain()
#endregion


#region menu buttons

func _on_play_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D/MenuAnimation.play("main", -1, -2, true)
	
	# Fade out / in + camera switch
	await get_tree().create_timer(1.0).timeout
	$Camera3D/FadeManager.play("fade")
	await get_tree().create_timer(1.0).timeout
	
	# Show game start notice
	$Camera3D/StartGameNoticeLayer.show()
	$Camera3D/StartGameNoticeLayer/MainLayer/StartGameNoticeAnimation.play("main")
	
	await get_tree().create_timer(3.0).timeout
	
	# Activate player & HUD
	global.player_active = true
	$"Player/Head/Camera3D".make_current()
	$"Player/Head/Camera3D/MainHUDLayer".show()
	
	# Hide firepit visuals
	$IslandComponents/firepit/FireParticles.hide()
	$IslandComponents/firepit/Tinder.hide()
	
	# Fade back
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
	await get_tree().create_timer(5.0).timeout
	
	# Start tutorial & conch task
	$Camera3D/StartGameNoticeLayer.hide()
	$Camera3D/TutorialLayer/ToastAnimation.play("main")
	$Timeline/ConchTask.start()
	global.player.start_timers()


func _on_continue_button_pressed() -> void:
	global.pause()

func _on_options_button_pressed() -> void:
	pass # TODO

func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion

#region conch handling

func _on_conch_used() -> void:
	global.PROGRESSION["CONCH_INTERACT_FIRST_TIME"] = true
	global.player_active = false
	$Camera3D/FadeManager.play("fade")
	
	await get_tree().create_timer(0.5).timeout
	
	$Player/Head/Camera3D/MainHUDLayer.hide()
	$Tasks/ConchTask/Arrow.hide()
	
	$ConchUseCutscene/Camera3D.make_current()
	$Camera3D/FadeManager.play("fade", -1, -1, true)
	$ConchUseCutscene.play("main")
	$conch/ConchInteractableComponent.hide()


func _on_conch_use_cutscene_animation_finished(_anim_name: StringName) -> void:
	await get_tree().create_timer(0.7).timeout
	$conch.transform = default_conch_transform
	
	# First meeting cutscene
	$FirstMeetingCutscene/Head/Camera3D.make_current()
	$Camera3D/DialogueCutsceneLayer/DialogueAnimations.play("first_conch")
	$Camera3D/FadeManager.play("fade", -1, -1, true)


func _on_conch_task_timeout() -> void:
	if !global.PROGRESSION["CONCH_INTERACT_FIRST_TIME"]:
		$Tasks/ConchTask/Arrow.show()
	task_system.task("BLOW_CONCH")


func _on_dialogue_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name != &"first_conch":
		return
	
	await get_tree().create_timer(1.0).timeout
	
	# Fade & hide characters
	$Camera3D/FadeManager.play("fade", -1, -1, true)
	for node in HideCharactersList:
		node.hide()
	$Player/Head/Camera3D/MainHUDLayer.show()
	
	# Update progression and UI
	global.PROGRESSION["HAD_FIRST_MEETING"] = true
	global.player.camera.make_current()
	$conch/ConchInteractableComponent.show()
	global.player_active = true
	
	# Adjust savagery
	global.savagery_level -= 20
	global.player.update_bar("SAVAGERY", global.savagery_level)
	
	# Start next task
	await get_tree().create_timer(2.0).timeout
	task_system.task("COLLECT_10_WOOD")
	global.player.wood_plank_info_anim.play(&"in")

#endregion

#region climb mountain area

func _on_climb_mountain_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		global.is_in_climb_mountain_area = true

func _on_climb_mountain_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		global.is_in_climb_mountain_area = false


func go_to_top_of_mountain() -> void:
	$Camera3D/FadeManager.play("fade")
	global.player_active = false
	global.is_on_top_of_mountain = true
	
	await get_tree().create_timer(1.0).timeout
	
	# Move player to top
	global.player.head.rotation_degrees = Vector3(0.0, -93.9, 0.0)
	global.player.camera.rotation_degrees = Vector3(-4.8, 0.0, 0.0)
	global.player.global_position = $PlayerMountainSpawn.global_position
	global.player_active = true
	
	global.player.climb_mountain_ui.hide()
	
	await get_tree().create_timer(1.0).timeout
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)

#endregion

#region firepit interaction

func _on_firepit_interacted() -> void:
	if !global.wood_placed:
		if global.wood_planks >= 10:
			global.wood_planks -= 10
			$IslandComponents/firepit/Tinder.show()
			$Audio/WoodCollect.play()
			global.wood_placed = true
			
			# Update interactable text
			$IslandComponents/firepit/InteractableComponent/Contents/UI/SubViewport/Key.text = "[F] to light fire"
		else:
			global.player.display_quick_message("Not enough wood planks!")
	else:
		if !global.fire_lighted:
			global.fire_lighted = true
			$Camera3D/FadeManager.play("fade")
			global.player_active = false
			
			await get_tree().create_timer(1.0).timeout
			$IslandComponents/firepit/FireParticles.show()
			
			$Camera3D/FadeManager.play("fade", -1, -0.35, true)
			global.player_active = true
			
			# Hide key text after lighting fire
			$IslandComponents/firepit/InteractableComponent/Contents/UI/SubViewport/Key.hide()

#endregion

#region misc

func make_wood_sound():
	$Audio/WoodCollect.play()

#endregion


func _on_climb_down_mountain_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		print("in")





func _on_climb_down_mountain_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		print("----        OUT")
