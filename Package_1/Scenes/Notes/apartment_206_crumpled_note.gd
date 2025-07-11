extends Node3D
class_name note

var ui : game_hud
var note_ui : notes
@export var note_to_read : note_res

func _ready() -> void:
	ui  = References.get_reference("ui")
	note_ui = ui.noteUI

func _on_interactable_interacted() -> void:
	if note_to_read == null:
		print("not was NOT set")
		return
	note_ui.start_showing_note(note_to_read)
