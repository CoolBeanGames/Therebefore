extends Node
class_name dialog_state

@export var manager : dialog_ui

func enter_state():
	if manager == null:
		manager = (References.get_reference("ui") as game_hud).dialogUI

func exit_state():
	pass

func next_state(new_state : dialog_state):
	if manager.current_state == self:
		manager.current_state = new_state
		exit_state()
		new_state.enter_state()
		print("entered " , manager.current_state.name)

func process():
	pass
