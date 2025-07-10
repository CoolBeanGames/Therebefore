extends Node3D
#this script was kept as a reference


@export var model : PackedScene 
@export var nodes_to_disable : Array[Node3D]

func _on_interactable_interacted() -> void:
	var ui : item_examine = References.get_reference("item_examine")
	ui.start_examine(model)
	ui.finish_examine.connect(on_finish)
	var ui_hud : game_hud = References.get_reference("ui")
	ui_hud.clear_interaction()
	for n in nodes_to_disable:
		n.visible = false
	pass # Replace with function body.

func on_finish():
	var ui : item_examine = References.get_reference("item_examine")
	ui.finish_examine.disconnect(on_finish)
	for n in nodes_to_disable:
		n.visible = true
