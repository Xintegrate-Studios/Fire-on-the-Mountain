extends Node3D

signal action_triggered

var interacting : bool = false
var player_area_box_active : bool = false
var mimic_raycast_box_active : bool = false

@export var Contents_Node : Node3D
@export var UI_Sprite_Node : Sprite3D
@export var SubViewport_Node : SubViewport

@export var ActionToPress : InputEventAction

func _ready() -> void:
	toggle_interacting(false)

func toggle_interacting(interacting_val : bool):
	Contents_Node.visible = interacting_val
	interacting = interacting_val

func _process(_delta: float) -> void:
	if player_area_box_active and mimic_raycast_box_active:
		toggle_interacting(true)
	else:
		toggle_interacting(false)

func _unhandled_input(_event: InputEvent) -> void:
	if interacting:
		if Input.is_action_just_pressed(ActionToPress.action):
			action_triggered.emit()

func _on_player_area_box_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		player_area_box_active = true

func _on_player_area_box_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"PlayerBody"):
		player_area_box_active = false

func _on_mimic_raycast_box_area_entered(area: Area3D) -> void:
	if area.is_in_group(&"raycast_mimic"):
		mimic_raycast_box_active = true

func _on_mimic_raycast_box_area_exited(area: Area3D) -> void:
	if area.is_in_group(&"raycast_mimic"):
		mimic_raycast_box_active = false
