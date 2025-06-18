extends interactive
class_name interactive_note

@export var note_to_pickup : Note
@export var remove_on_pickup : bool = false

func interact():
	if !GameData.is_input_locked():
		var ui : note_ui = GameData.references["NoteUI"]
		ui.show_note(note_to_pickup)
		ui.note_closed.connect(on_note_closed)
		super.interact()

func on_note_closed():
	if remove_on_pickup:
		stop_looking()
		parent.queue_free()
	else:
		var ui : note_ui = GameData.references["NoteUI"]
		ui.note_closed.disconnect(on_note_closed)
	pass
