extends Node

var player_active : bool = true
var paused : bool = false

var did_tutorial : bool = false

var world
var player
var pause_animation_player

var savagery_level : float = 10.0
var conch_effectiveness : float = 100.0
var fire_fuel : float = 100.0

var PROGRESSION : Dictionary = {
	"CONCH_INTERACT_FIRST_TIME" : false,
	"HAD_FIRST_MEETING" : false
}
var wood_planks : int = 0

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
