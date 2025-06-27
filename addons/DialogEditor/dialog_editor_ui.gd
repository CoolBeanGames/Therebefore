@tool
extends Control
class_name dialog_editor

const note_path = "res://Data/Dialog"

var audio : Array[AudioStream]
@export var click_sound_player : AudioStreamPlayer
@export var save_sound_player : AudioStreamPlayer
@export var reload_sound_player : AudioStreamPlayer
@export var new_file_sound_player : AudioStreamPlayer
@export var delete_sound_player : AudioStreamPlayer

@export var audio_selection_list : OptionButton

@export var dialog_data : Dictionary[String, dialog_res]

@export var dialog_list : ItemList
@export var item_list_pointer_icon : Texture

@export var dialog_name : LineEdit

@export var dialog_selected_index : int = -1
@export var dialog_selected_name : String = ""
@export var dialog_selected_res : dialog_res
@export var text_entry : TextEdit
@export var page_count_label : Label

@export var flags_text : TextEdit
var dialog_page_index : int = 0

var plugin : EditorPlugin

func setup(plug : EditorPlugin):
	plugin = plug

func get_all_audio_streams() -> Array[AudioStream]:
	var results: Array[AudioStream] = []
	var file_system := plugin.get_editor_interface().get_resource_filesystem().get_filesystem()
	_scan_dir_for_audio(file_system, results)
	return results

func _scan_dir_for_audio(dir: EditorFileSystemDirectory, results: Array[AudioStream]) -> void:
	for i in dir.get_file_count():
		var path = dir.get_file_path(i)
		var type = dir.get_file_type(i)
		var extension = path.get_extension().to_lower()
		if type.begins_with("AudioStream") or extension in ["ogg", "wav", "mp3", "flac"]:
			var stream: AudioStream = ResourceLoader.load(path)
			if stream:
				results.append(stream)
				audio_selection_list.add_item(stream.resource_path)

	for i in dir.get_subdir_count():
		_scan_dir_for_audio(dir.get_subdir(i), results)



func reload_clicked() -> void:
	check_directory()
	play_reload()
	dialog_list.clear()
	audio_selection_list.clear()
	audio = get_all_audio_streams()
	get_all_dialog()

func play_click():
	if click_sound_player!=null:
		click_sound_player.play()

func on_dialog_selected(index: int) -> void:
	play_click()
	remove_icon_from_all_entries()
	dialog_list.set_item_icon(index,item_list_pointer_icon)
	
	dialog_selected_index = index
	dialog_selected_name = dialog_list.get_item_text(index)
	dialog_selected_res = dialog_data[dialog_selected_name]
	
	set_data()

func remove_icon_from_all_entries():
	for i in dialog_list.get_item_count():
		dialog_list.set_item_icon(i, null)

func play_save():
	if save_sound_player!=null:
		save_sound_player.play()

func play_reload():
	if reload_sound_player!=null:
		reload_sound_player.play()

func play_delete():
	if delete_sound_player!=null:
		delete_sound_player.play()

func play_new():
	if new_file_sound_player!=null:
		new_file_sound_player.play()

func save_all() -> void:
	play_save()
	for n in dialog_data:
		ResourceSaver.save(dialog_data[n],dialog_data[n].resource_path)
		print("saved ", dialog_data[n])

func save_selected() -> void:
	play_save()
	if dialog_selected_res:
		print("Saving to path: ", dialog_selected_res.resource_path)
		var save_path = dialog_selected_res.resource_path
		if save_path == "":
			save_path = note_path.path_join(dialog_selected_res.resource_name + ".tres")
		var err := ResourceSaver.save(dialog_selected_res, save_path)
		print("Save result: ", err)
		if err != OK:
			push_error("Failed to save note. Error code: %d" % err)
		dialog_selected_res.emit_changed()
		print("saved note")

func delete_selected() -> void:
	play_delete()
	print("deleting note")
	if dialog_selected_res == null:
		push_warning("No note selected to delete.")
		return

	# Get the file path and check it exists
	var file_path = dialog_selected_res.resource_path
	if file_path == "":
		file_path = note_path.path_join(dialog_selected_res.resource_name + ".tres")

	if not ResourceLoader.exists(file_path):
		push_error("Note file does not exist: " + file_path)
	else:
		var err = DirAccess.remove_absolute(file_path)
		if err != OK:
			push_error("Failed to delete note file. Error code: %d" % err)
		else:
			print("Deleted note: ", file_path)

	# Remove from list
	if dialog_selected_name != "":
		if dialog_data.has(dialog_selected_name):
			dialog_data.erase(dialog_selected_name)
		for i in dialog_list.get_item_count():
			if dialog_list.get_item_text(i) == dialog_selected_name:
				dialog_list.remove_item(i)
				break

	# Clear selection
	dialog_selected_res = null
	dialog_selected_name = ""
	dialog_selected_index = -1
	dialog_page_index = 0
	clear_data()
	remove_icon_from_all_entries()

	# Refresh asset database
	EditorInterface.get_resource_filesystem().scan()

func make_new_note() -> void:
	play_new()
	var name = dialog_name.text
	if name == "" or name.strip_edges() == "":
		return
	var n := dialog_res.new()
	n.resource_name = name
	var path = note_path.path_join(name + ".tres")
	n.resource_path = path
	ResourceSaver.save(n,path)
	dialog_data[name] = n
	dialog_list.add_item(name)
	dialog_name.clear()

func on_page_left() -> void:
	play_click()
	if dialog_selected_res:
		dialog_page_index -= 1
		clamp_page_index()
		update_page_counter()
		set_text_from_res()

func on_page_delete() -> void:
	play_delete()
	if dialog_selected_res:
		dialog_selected_res.remove_page(dialog_page_index)
		check_page()
		update_page_counter()

func on_add_page() -> void:
	play_new()
	if dialog_selected_res:
		dialog_selected_res.add_page()
		update_page_counter()

func on_page_right() -> void:
	play_click()
	if dialog_selected_res:
		dialog_page_index += 1
		clamp_page_index()
		update_page_counter()
		set_text_from_res()

func _ready() -> void:
	call_deferred("check_directory")
	call_deferred("reload_clicked")

func get_all_dialog(folder := "res://") -> Array[dialog_res]:
	if folder == "res://":
		clear_all_dialog()

	var dialog: Array[dialog_res] = []
	var dir := DirAccess.open(folder)
	if not dir:
		push_error("Could not open folder: %s" % folder)
		return dialog

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := folder.path_join(file_name)
		if dir.current_is_dir():
			dialog += get_all_dialog(full_path)  # Recurse
		elif file_name.get_extension() in ["tres", "res"]:
			var res = ResourceLoader.load(full_path)
			if res is dialog_res:
				if res.resource_name != "":
					dialog.append(res)
					dialog_list.add_item(res.resource_name)
					dialog_data[res.resource_name] = res
				else:
					printerr("Note at ", full_path, " has no resource name!")
		file_name = dir.get_next()
	dir.list_dir_end()

	# Only print once, from the top-level call
	if folder == "res://":
		print("Found ", dialog.size(), " notes total")
	return dialog

func clear_all_dialog():
	dialog_list.clear()
	dialog_data.clear()

func check_directory():
	var dir := DirAccess.open("res://")
	if not dir:
		push_error("Failed to open res://")
		return
	
	if not dir.dir_exists(note_path):
		print("Directory doesn't exist: ", note_path)
		var result := dir.make_dir_recursive(note_path)
		if result == OK:
			print("Successfully made directory: ", note_path)
			# Schedule the scan to run on the next idle frame.
			# This gives Godot's main thread a chance to finish current operations
			# before initiating a potentially blocking scan that updates the UI.
			EditorInterface.get_resource_filesystem().call_deferred("scan") 
		else:
			print("Failed to make directory, error: ", result)
	# No unconditional scan here.


func note_clear(at_position: Vector2, mouse_button_index: int) -> void:
	dialog_list.deselect_all()
	dialog_selected_index = -1
	dialog_selected_name = ""
	dialog_selected_res = null
	remove_icon_from_all_entries()
	clear_data()
	update_page_counter()

func set_data():
	if dialog_selected_res != null:
		check_page()
		set_audio_from_res()
		set_text_from_res()
		update_page_counter()
	else:
		clear_data()
	pass

func clear_data():
	update_page_counter()
	text_entry.text = ""
	pass

func check_page():
	if dialog_selected_res !=null:
		if dialog_selected_res.lines.size() == 0 or dialog_selected_res.lines == null:
			dialog_selected_res.add_page()

func update_page_counter():
	if dialog_selected_res != null:
		var index_counter : String = str(dialog_page_index + 1)
		var max_index : String  = str(dialog_selected_res.lines.size())
		page_count_label.text = index_counter + " / " + max_index
	else:
		page_count_label.text = "-- / --"

func clamp_page_index():
	if dialog_selected_res != null:
		dialog_page_index = clamp(dialog_page_index,0,dialog_selected_res.lines.size() - 1)

func set_audio_from_res():
	if dialog_selected_res!=null:
		if dialog_selected_res.audio != null and audio.size() > 0:
			var ind = audio.find(dialog_selected_res.audio[dialog_page_index])
			audio_selection_list.select(ind)

func set_text_from_res():
	text_entry.text = dialog_selected_res.lines[dialog_page_index]


func text_edit_finished() -> void:
	if dialog_selected_res:
		dialog_selected_res.lines[dialog_page_index] = text_entry.text
		print("finished editing text")
	else:
		text_entry.text = ""

func set_res_audio(index : int):
	if dialog_selected_res:
		print("attempteing to set audio")
		print("index is ",index)
		print("dialog audio size: ",dialog_selected_res.audio.size())
		print("audio array size:", audio.size())
		dialog_selected_res.audio[dialog_page_index] = audio[index]

func new_note_enter(new_text: String) -> void:
	make_new_note()

func parse_csv_string(input: String) -> Array[String]:
	var raw_values: PackedStringArray = input.split(",")
	var cleaned_values: Array[String] = []
	for val in raw_values:
		cleaned_values.append(val.strip_edges())
	return cleaned_values


func flags_updated() -> void:
	if dialog_selected_res:
		dialog_selected_res.flags = parse_csv_string(flags_text.text)
		print("updated flags")
	else:
		flags_text.text = ""


func check_button_toggle(toggled_on: bool) -> void:
	if dialog_selected_res:
		dialog_selected_res.use_position[dialog_page_index] = toggled_on
