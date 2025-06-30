extends CanvasLayer
class_name game_hud

@export var noteUI : notes

func _ready() -> void:
	await get_tree().process_frame
	show_note(load("res://Data/Notes/test_newspaper.tres"))

func show_note(note : note_res):
	noteUI.start_showing_note(note)
	
