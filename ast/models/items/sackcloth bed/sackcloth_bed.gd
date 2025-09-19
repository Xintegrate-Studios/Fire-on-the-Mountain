extends Node3D


func _on_player_sleep() -> void:
	if global.fire_lighted:
		if !global.slept:
			global.world.sleep()
			$InteractableComponent.hide()
	else:
		global.player.display_quick_message("You must complete your tasks first!")
