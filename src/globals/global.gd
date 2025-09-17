extends Node

var player_active : bool = true
var paused : bool = false

var did_tutorial : bool = false
var is_in_climb_mountain_area : bool = false:
	set(value):
		is_in_climb_mountain_area = value
		player.climb_mountain_ui.visible = value

var world
var player
var pause_animation_player

var savagery_level : float = 10.0
var conch_effectiveness : float = 100.0
var fire_fuel : float = 100.0

var is_on_top_of_mountain : bool = false

var wood_placed : bool = false
var fire_lighted : bool = false

var PROGRESSION : Dictionary = {
	"CONCH_INTERACT_FIRST_TIME" : false,
	"HAD_FIRST_MEETING" : false,
	"FIRST_TIME_LIGHTING_FIRE" : true,
}
var wood_planks : int = 0:
	set(value):
		var old_value = wood_planks
		wood_planks = value
		
		if wood_planks > old_value:
			player.wood_plank_plus_animation()
		
		if value == 10 and PROGRESSION["FIRST_TIME_LIGHTING_FIRE"]:
			PROGRESSION["FIRST_TIME_LIGHTING_FIRE"] = false
			task_system.task("LIGHT_FIRE")

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
