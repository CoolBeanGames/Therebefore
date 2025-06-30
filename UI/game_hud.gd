extends CanvasLayer
class_name game_hud

@export var noteUI : notes
@export var interaction_text : Label

func _ready() -> void:
	References.add_custom("ui",self)

func show_note(note : note_res):
	noteUI.start_showing_note(note)

func set_interaction(string : String):
	interaction_text.text = string

func clear_interaction():
	interaction_text.text = ""
