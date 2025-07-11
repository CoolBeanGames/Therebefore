extends dialog_state
class_name dialog_next

func enter_state():
	super.enter_state()
	#check to see if we are within the correct range
	if manager.current_dialog == null or manager.current_dialog.lines.size() - 1 < manager.dialog_index:
		#if not end the dialog
		next_state(manager.end_state)
		return
	
	#set text
	print("setting text to :" , manager.current_dialog.lines[manager.dialog_index])
	print("current index: " , manager.dialog_index)
	print("of: " , manager.current_dialog.resource_name)
	manager.text.text = manager.current_dialog.lines[manager.dialog_index]
	
	#play audio
	manager.current_audio_player = Audio.play(manager.current_dialog.audio[manager.dialog_index],false,manager.current_dialog.bus[manager.dialog_index],manager.current_dialog.use_position[manager.dialog_index],manager.current_position)
	
	#connect audio signals
	manager.current_audio_player.audio_finished.connect(on_audio_finished)

func exit_state():
	super.exit_state()
	manager.dialog_index += 1

func next_state(new_state : dialog_state):
	super.next_state(new_state)

func process():
	super.process()

func on_audio_finished(audio):
	#start a timer
	manager.current_audio_player.audio_finished.disconnect(on_audio_finished)
	var t = manager.get_tree().create_timer(0.5,false)
	t.timeout.connect(on_timer_finished)

func on_timer_finished():
	next_state(manager.next_state)
