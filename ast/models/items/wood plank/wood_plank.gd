extends Node3D

func _on_wood_plank_collected() -> void:
	global.wood_planks += 1
	print("wood plank collected! wood planks: " + str(global.wood_planks))
	queue_free()
