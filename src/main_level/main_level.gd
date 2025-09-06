extends Node3D

func _ready() -> void:
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
	await get_tree().create_timer(3.0).timeout
	global.player_active = true
	$"Player/Head/Camera3D".make_current()
	$"Player/Head/Camera3D/MainHUDLayer".show()
	
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
	
	await get_tree().create_timer(5.0).timeout
	$Camera3D/TutorialLayer/ToastAnimation.play("main")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Tutorial"):
		pass

func _on_continue_button_pressed() -> void:
	global.pause()

func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
