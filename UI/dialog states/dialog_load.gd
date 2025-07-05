extends dialog_state
class_name dialog_load

func enter_state():
	super.enter_state()
	manager.visible = true
	manager.dialog_index = 0

func exit_state():
	super.exit_state()

func next_state(new_state : dialog_state):
	super.next_state(new_state)

func process():
	super.process()
