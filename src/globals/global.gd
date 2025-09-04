extends Node

var player_active : bool = true
var paused : bool = false

var world
var player
var pause_animation_player

func pause():
	paused = !paused
	get_tree().paused = paused
	
	if paused:
		pause_animation_player.play(&"main")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		pause_animation_player.play(&"main", -1, -2, true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(_event: InputEvent) -> void:
	if OS.is_debug_build():
		if Input.is_action_just_pressed("Quit") and player.AllowQuitInput:
			get_tree().quit()
