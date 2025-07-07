@tool
extends Control
class_name note_editor

const note_path = "res://Data/Notes"

var textures : Array[Texture2D]
@export var click_sound_player : AudioStreamPlayer
@export var save_sound_player : AudioStreamPlayer
@export var reload_sound_player : AudioStreamPlayer
@export var new_file_sound_player : AudioStreamPlayer
@export var delete_sound_player : AudioStreamPlayer

@export var texture_selection_list : OptionButton

@export var notes_data : Dictionary[String, note_res]

@export var note_list : ItemList
@export var item_list_pointer_icon : Texture

@export var note_name : LineEdit

@export var note_selected_index : int = -1
@export var note_selected_name : String = ""
@export var note_selected_res : note_res
@export var note_page_index : int = 0

@export var text_entry : TextEdit
@export var page_count_label : Label

@export var flags_text : TextEdit

@export var music_player : AudioStreamPlayer
@export var music_playing : bool = false


@export var toggle_music_button : Button
@export var music_on : bool = true

@export var playlist : editor_playlist

@export var track_name : Label

var plugin : EditorPlugin

func setup(plug : EditorPlugin):
	plugin = plug

func get_all_textures() -> Array[Texture2D]:
	var results: Array[Texture2D] = []
	var file_system := EditorInterface.get_resource_filesystem()
	_scan_dir_for_textures(file_system.get_filesystem(), results)
	return results

func _scan_dir_for_textures(dir: EditorFileSystemDirectory, results: Array[Texture2D]) -> void:
	for i in dir.get_file_count():
		var path = dir.get_file_path(i)
		var type = dir.get_file_type(i)
		if type == "Texture2D" or type == "CompressedTexture2D":
			var texture := ResourceLoader.load(path)
			if texture:
				results.append(texture)
				texture_selection_list.add_item(texture.resource_path)

	for i in dir.get_subdir_count():
		_scan_dir_for_textures(dir.get_subdir(i), results)

func reload_clicked() -> void:
	play_reload()
	texture_selection_list.clear()
	textures = get_all_textures()
	get_all_notes()

func play_click():
	if click_sound_player!=null and music_playing:
		click_sound_player.play()

func on_note_selected(index: int) -> void:
	play_click()
	remove_icon_from_all_entries()
	note_list.set_item_icon(index,item_list_pointer_icon)
	
	note_selected_index = index
	note_selected_name = note_list.get_item_text(index)
	note_selected_res = notes_data[note_selected_name]
	
	set_data()

func remove_icon_from_all_entries():
	for i in note_list.get_item_count():
		note_list.set_item_icon(i, null)

func play_save():
	if save_sound_player!=null and music_playing:
		save_sound_player.play()

func play_reload():
	if reload_sound_player!=null and music_playing:
		reload_sound_player.play()

func play_delete():
	if delete_sound_player!=null and music_playing:
		delete_sound_player.play()

func play_new():
	if new_file_sound_player!=null and music_playing:
		new_file_sound_player.play()

func save_all() -> void:
	play_save()
	for n in notes_data:
		ResourceSaver.save(notes_data[n],notes_data[n].resource_path)

func save_selected() -> void:
	play_save()
	if note_selected_res:
		var save_path = note_selected_res.resource_path
		if save_path == "":
			save_path = note_path.path_join(note_selected_res.resource_name + ".tres")
		var err := ResourceSaver.save(note_selected_res, save_path)
		if err != OK:
			push_error("Failed to save note. Error code: %d" % err)
		note_selected_res.emit_changed()

func delete_selected() -> void:
	play_delete()
	if note_selected_res == null:
		push_warning("No note selected to delete.")
		return

	# Get the file path and check it exists
	var file_path = note_selected_res.resource_path
	if file_path == "":
		file_path = note_path.path_join(note_selected_res.resource_name + ".tres")

	if not ResourceLoader.exists(file_path):
		push_error("Note file does not exist: " + file_path)
	else:
		var err = DirAccess.remove_absolute(file_path)
		if err != OK:
			push_error("Failed to delete note file. Error code: %d" % err)

	# Remove from list
	if note_selected_name != "":
		if notes_data.has(note_selected_name):
			notes_data.erase(note_selected_name)
		for i in note_list.get_item_count():
			if note_list.get_item_text(i) == note_selected_name:
				note_list.remove_item(i)
				break

	# Clear selection
	note_selected_res = null
	note_selected_name = ""
	note_selected_index = -1
	note_page_index = 0
	clear_data()
	remove_icon_from_all_entries()

	# Refresh asset database
	EditorInterface.get_resource_filesystem().scan()

func make_new_note() -> void:
	play_new()
	var name = note_name.text
	if name == "" or name.strip_edges() == "":
		return
	var n := note_res.new()
	n.resource_name = name
	var path = note_path.path_join(name + ".tres")
	n.resource_path = path
	ResourceSaver.save(n,path)
	notes_data[name] = n
	note_list.add_item(name)
	note_name.clear()

func on_page_left() -> void:
	play_click()
	if note_selected_res:
		note_page_index -= 1
		clamp_page_index()
		update_page_counter()
		set_text_from_res()

func on_page_delete() -> void:
	play_delete()
	if note_selected_res:
		note_selected_res.remove_page(note_page_index)
		check_page()
		if note_page_index != 0 and note_page_index > note_selected_res.pages.size()-1:
			note_page_index -= 1
		set_data()
		update_page_counter()

func on_add_page() -> void:
	play_new()
	if note_selected_res:
		note_selected_res.add_page("")
		note_page_index+=1
		set_data()
		update_page_counter()

func on_page_right() -> void:
	play_click()
	if note_selected_res:
		note_page_index += 1
		clamp_page_index()
		update_page_counter()
		set_text_from_res()

func _ready() -> void:
	call_deferred("reload_clicked")

func get_all_notes(folder := "res://") -> Array[note_res]:
	if folder == "res://":
		clear_all_notes()

	var notes: Array[note_res] = []
	var dir := DirAccess.open(folder)
	if not dir:
		push_error("Could not open folder: %s" % folder)
		return notes

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := folder.path_join(file_name)
		if dir.current_is_dir():
			notes += get_all_notes(full_path)  # Recurse
		elif file_name.get_extension() in ["tres", "res"]:
			var res = ResourceLoader.load(full_path)
			if res is note_res:
				if res.resource_name != "":
					notes.append(res)
					note_list.add_item(res.resource_name)
					notes_data[res.resource_name] = res
				else:
					printerr("Note at ", full_path, " has no resource name!")
		file_name = dir.get_next()
	dir.list_dir_end()
	return notes

func clear_all_notes():
	note_list.clear()
	notes_data.clear()

func check_directory():
	var dir := DirAccess.open("res://")
	if not dir:
		push_error("Failed to open res://")
		return
	
	if not dir.dir_exists(note_path):
		print("Directory doesn't exist: ", note_path)
		var result := dir.make_dir_recursive(note_path)
		if result == OK:
			print("Successfully made directory")
		else:
			print("Failed to make directory, error: ", result)
	EditorInterface.get_resource_filesystem().scan()

func note_clear(at_position: Vector2, mouse_button_index: int) -> void:
	note_list.deselect_all()
	note_selected_index = -1
	note_selected_name = ""
	note_selected_res = null
	remove_icon_from_all_entries()
	clear_data()
	update_page_counter()

func set_data():
	if note_selected_res != null:
		check_page()
		set_texture_from_res()
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
	if note_selected_res !=null:
		if note_selected_res.pages.size() == 0 or note_selected_res.pages == null:
			note_selected_res.add_page("")

func update_page_counter():
	if note_selected_res != null:
		var index_counter : String = str(note_page_index + 1)
		var max_index : String  = str(note_selected_res.pages.size())
		page_count_label.text = index_counter + " / " + max_index
	else:
		page_count_label.text = "-- / --"

func clamp_page_index():
	if note_selected_res != null:
		note_page_index = clamp(note_page_index,0,note_selected_res.pages.size() - 1)

func set_texture_from_res():
	if note_selected_res!=null:
		if note_selected_res.image != null:
			var ind = textures.find(note_selected_res.image)
			texture_selection_list.select(ind)

func set_text_from_res():
	text_entry.text = note_selected_res.pages[note_page_index]


func text_edit_finished() -> void:
	if note_selected_res:
		note_selected_res.pages[note_page_index] = text_entry.text
	else:
		text_entry.text = ""

func set_res_texture(index : int):
	if note_selected_res:
		note_selected_res.image = textures[index]

func new_note_enter(new_text: String) -> void:
	make_new_note()

func parse_csv_string(input: String) -> Array[String]:
	var raw_values: PackedStringArray = input.split(",")
	var cleaned_values: Array[String] = []
	for val in raw_values:
		cleaned_values.append(val.strip_edges())
	return cleaned_values


func flags_updated() -> void:
	if note_selected_res:
		note_selected_res.flags = parse_csv_string(flags_text.text)
	else:
		flags_text.text = ""


func start_music():
	if music_player and not music_playing: # Use 'not' for clarity, equivalent to '!'.
		music_player.stream= playlist.get_track()
		track_name.text = music_player.stream.resource_path.get_file().get_basename()
		music_player.play()
		music_playing = true # Update state
		print("Music Started") # Debug print

func end_music():
	if music_player and music_playing:
		music_player.stop()
		music_playing = false # Update state
		print("Music Ended") # Debug print

# Updated function to accept the visibility state directly
func toggle_music(is_plugin_visible: bool):
	if is_plugin_visible and music_on:
		start_music()
	else:
		end_music()


func toggle_music_pressed() -> void:
	music_on = !music_on
	if music_on:
		toggle_music_button.text = "Toggle Music (On)"
		if !music_player.playing:
			start_music()
	else:
		toggle_music_button.text = "Toggle Music (Off)"
		end_music()

func last_page_button_pressed() -> void:
	play_click()
	if note_selected_res:
		note_page_index = note_selected_res.pages.size()-1
		clamp_page_index()
		update_page_counter()
		set_data()


func first_page_button_pressed() -> void:
	play_click()
	if note_selected_res:
		note_page_index = 0
		clamp_page_index()
		update_page_counter()
		set_data()


func play_next_track_pressed() -> void:
	end_music()
	start_music()
