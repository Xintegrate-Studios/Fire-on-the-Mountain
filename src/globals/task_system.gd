extends Node

const TASKS = {
	"BLOW_CONCH" : "Blow the conch to assemble everyone."
}

func task(task_name : String):
	global.player.display_task(TASKS[task_name])
