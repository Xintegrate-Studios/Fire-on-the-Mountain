extends Node

var player_active : bool = true
var paused : bool = false

var world

func pause():
	paused = !paused
	get_tree().paused = paused
