extends Node

const TASKS = {
	"BLOW_CONCH" : "Blow the conch to assemble everyone.",
	"COLLECT_10_WOOD" : "Collect 10 wood planks for the fire on the mountain.",
}

func task(task_name : String):
	global.player.display_task(TASKS[task_name])
