extends dialog_state
class_name dialog_end

func enter_state():
	super.enter_state()
	manager.visible=false
	manager.dialog_finished.emit()
	next_state(manager.idle_state)

func exit_state():
	super.exit_state()

func next_state(new_state : dialog_state):
	super.next_state(new_state)

func process():
	super.process()
