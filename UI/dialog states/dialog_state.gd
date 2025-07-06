extends Node
class_name dialog_state

@export var manager : dialog_ui
@export var cls : String

func enter_state():
	if manager == null:
		manager = (References.get_reference("ui") as game_hud).dialogUI
	manager.current_state = self

func exit_state():
	pass

func next_state(new_state : dialog_state):
	if manager.current_state == self:
		exit_state()
		new_state.enter_state()
		print("entered " , new_state.cls)

func process():
	pass
