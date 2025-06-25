extends Resource
class_name note_res

@export var pages : Array[String]
@export var image : Texture
@export var flags : Array[String]

signal note_read

#read the note (emit signal and set all flags)
func read_note():
	note_read.emit()
	for f in flags:
		pass #set flags to true here

#called to add a page to the list
func add_page(text : String):
	pages.append(text)

#called to move page backward (index -1)
func move_page_back(index : int):
	if index <= 0 or index >= pages.size():
		printerr("Attempted to move page back but index out of range or index was 0")
		return
	var page_to_move = pages[index]
	pages.remove_at(index)
	pages.insert(index-1,page_to_move)

#called to move page forweard (index + 1)
func move_page_forward(index : int):
	if index < 0 or index >= pages.size() - 1:
		printerr("Attempted to move page back but index out of range or index was last")
		return
	var page_to_move = pages[index]
	pages.insert(index+1,page_to_move)
	pages.remove_at(index)

func remove_page(index : int):
	if index<0 or index > pages.size()-1:
		printerr("Attempted to remove a page but index was out of bounds")
		return
	pages.remove_at(index)
