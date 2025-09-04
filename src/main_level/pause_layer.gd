extends CanvasLayer

func _input(_event: InputEvent) -> void:
	if global.player_active:
		if Input.is_action_just_pressed("Pause"):
			global.pause()
