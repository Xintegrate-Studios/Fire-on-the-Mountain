extends Node3D

func _ready() -> void:
	global.player_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Camera3D/MenuAnimation.play("main")


func _on_play_button_pressed() -> void:
	$Camera3D/MenuAnimation.play("main", -1, -2, true)
	
	
	# Fade in and out, + camera switch
	await get_tree().create_timer(1.0).timeout
	$Camera3D/FadeManager.play("fade")
	await get_tree().create_timer(3.0).timeout
	$Camera3D/FadeManager.play("fade", -1, -0.35, true)
