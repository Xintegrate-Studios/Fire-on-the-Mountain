extends Node3D


func _on_player_sleep() -> void:
	if global.fire_lighted:
		global.player.sleep() # TODO
	else:
		global.player.display_quick_message("You must complete your tasks first!")
