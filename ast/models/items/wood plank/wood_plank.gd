extends Node3D

func _on_wood_plank_collected() -> void:
	if global.PROGRESSION["HAD_FIRST_MEETING"]:
		global.wood_planks += 1
		global.world.make_wood_sound()
		print("wood plank collected! wood planks: " + str(global.wood_planks))
		queue_free()
	else:
		global.player.display_quick_message("Call a meeting using the 
		conch before collecting wood!")
