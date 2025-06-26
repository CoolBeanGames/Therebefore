@tool
extends Resource
class_name dialog_res

@export var lines : Array[String]
@export var audio : Array[AudioStream]
@export var flags : Array[String]
@export var use_position : Array[bool]

signal note_read

#read the note (emit signal and set all flags)
func read_note():
	note_read.emit()
	for f in flags:
		pass #set flags to true here

#called to add a page to the list
func add_page():
	audio.append(null)
	use_position.append(false)
	lines.append("")

#called to move page backward (index -1)
func move_page_back(index : int):
	if index <= 0 or index >= lines.size():
		printerr("Attempted to move page back but index out of range or index was 0")
		return
	var line_to_move = lines[index]
	var audio_to_move = audio[index]
	var use_position_to_move = use_position[index]
	
	lines.remove_at(index)
	lines.insert(index-1,line_to_move)
	
	audio.remove_at(index)
	audio.insert(index-1,audio_to_move)
	
	use_position.remove_at(index)
	use_position.insert(index-1,use_position_to_move)

#called to move page forweard (index + 1)
func move_page_forward(index : int):
	if index < 0 or index >= lines.size() - 1:
		printerr("Attempted to move page back but index out of range or index was last")
		return
	var line_to_move = lines[index]
	var audio_to_move = audio[index]
	var use_position_to_move = use_position[index]
	
	
	lines.remove_at(index)
	lines.insert(index+1,line_to_move)
	
	audio.remove_at(index)
	audio.insert(index+1,audio_to_move)
	
	use_position.remove_at(index)
	use_position.insert(index+1,use_position_to_move)

func remove_page(index : int):
	if index<0 or index > lines.size()-1:
		printerr("Attempted to remove a page but index was out of bounds")
		return
	lines.remove_at(index)
	audio.remove_at(index)
	use_position.remove_at(index)
