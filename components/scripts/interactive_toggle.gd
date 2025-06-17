extends interactive
class_name interactive_toggle

enum toggle_state{off = 0,on = 1}

@export var state : toggle_state = toggle_state.off
@export var display_text_on : String = ""
@export var display_text_off : String = ""

func _ready() -> void:
	toggle_display_text()
	super._ready()

func interact():	
	state += 1
	if(state > 1):
		state = 0
#update display text
	toggle_display_text()
	start_looking()
	super.interact()
	print(state)


func toggle_display_text():
	if state == 0:
		display_text = display_text_off
	else:
		display_text = display_text_on
