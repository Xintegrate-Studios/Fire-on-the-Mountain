extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Camera3D/MenuAnimation.play("main")


func _on_play_button_pressed() -> void:
	$Camera3D/MenuAnimation.play("main", -1, -2, true)
