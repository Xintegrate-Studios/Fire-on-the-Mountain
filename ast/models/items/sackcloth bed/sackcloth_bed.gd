extends Node3D


func _on_player_sleep() -> void:
	if global.fire_lighted:
		pass
	else:
		global.player.display_quick_message("Not enough wood planks!")
