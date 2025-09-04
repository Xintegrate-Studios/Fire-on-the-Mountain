extends Node3D

func _ready() -> void:
	global.world = self
	global.player_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"3DPlayer/Head/Camera3D/MainHUDLayer".hide()
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
	$"3DPlayer/Head/Camera3D".make_current()
	$"3DPlayer/Head/Camera3D/MainHUDLayer".show()
	
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
