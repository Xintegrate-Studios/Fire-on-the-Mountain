extends Node3D

var default_conch_transform

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

func _ready() -> void:
	default_conch_transform = $conch.transform
	global.world = self
	global.player = $"Player"
	global.pause_animation_player = $Camera3D/PauseAnimation
	global.player_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"Player/Head/Camera3D/MainHUDLayer".hide()
	
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
	
	await get_tree().create_timer(0.5).timeout
	$Camera3D/MenuAnimation.play("main")


func _on_play_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D/MenuAnimation.play("main", -1, -2, true)
	
	
	# Fade in and out, + camera switch
	await get_tree().create_timer(1.0).timeout
	$Camera3D/FadeManager.play("fade")
	await get_tree().create_timer(1.0).timeout
	$Camera3D/StartGameNoticeLayer.show()
	$Camera3D/StartGameNoticeLayer/MainLayer/StartGameNoticeAnimation.play("main")
	
	
	await get_tree().create_timer(3.0).timeout
	global.player_active = true
	$"Player/Head/Camera3D".make_current()
	$"Player/Head/Camera3D/MainHUDLayer".show()
	
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
	
	await get_tree().create_timer(5.0).timeout
	$Camera3D/StartGameNoticeLayer.hide()
	
	$Camera3D/TutorialLayer/ToastAnimation.play("main")
	$Timeline/ConchTask.start()
	global.player.start_timers()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Tutorial"):
		pass

func _on_continue_button_pressed() -> void:
	global.pause()

func _on_options_button_pressed() -> void:
	pass # TODO

func _on_quit_button_pressed() -> void:
	get_tree().quit()


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
	
	# first meeting cutscene
	$FirstMeetingCutscene/Head/Camera3D.make_current()
	$Camera3D/DialogueCutsceneLayer/DialogueAnimations.play("first_conch")
	$Camera3D/FadeManager.play("fade", -1, -1, true)


func _on_conch_task_timeout() -> void:
	if !global.PROGRESSION["CONCH_INTERACT_FIRST_TIME"] == true:
		$Tasks/ConchTask/Arrow.show()
	task_system.task("BLOW_CONCH")


func _on_dialogue_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == "first_conch":
		
		await get_tree().create_timer(1.0).timeout
		$Camera3D/FadeManager.play("fade", -1, -1, true)
		$Player/Head/Camera3D/MainHUDLayer.show()
		global.PROGRESSION["HAD_FIRST_MEETING"] = true
		
		global.player.camera.make_current()
		
		$conch/ConchInteractableComponent.show()
		global.player_active = true
		
		await get_tree().create_timer(2.0).timeout
		
		task_system.task("COLLECT_10_WOOD")
		global.player.wood_plank_info_anim.play(&"in")
