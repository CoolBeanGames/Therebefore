extends Node3D
class_name test_note

@export var note_to_read : note_res

func _on_interactable_interacted() -> void:
	var ui : game_hud =  References.get_reference("ui") 
	ui.show_note(note_to_read)
