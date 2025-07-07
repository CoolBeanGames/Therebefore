# dialog_editor_ui.gd

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
@export var bus_selection : OptionButton

@export var dialog_data : Dictionary[String, dialog_res]

@export var dialog_list : ItemList
@export var item_list_pointer_icon : Texture

@export var dialog_name : LineEdit

@export var dialog_selected_index : int = -1
@export var dialog_selected_name : String = ""
@export var dialog_selected_res : dialog_res
@export var text_entry : TextEdit
@export var page_count_label : Label
@export var checkButton : CheckButton

@export var flags_text : TextEdit

@export var music_player : AudioStreamPlayer
@export var line_preview_player: AudioStreamPlayer
@export var music_playing : bool = false

@export var toggle_music_button : Button
@export var music_on : bool = true

var dialog_page_index : int = 0

var plugin : dialog_editor_plugin

func setup(plug : EditorPlugin):
	plugin = plug

# Removed the problematic get_tree() == null check from here.
# This function can now assume get_tree() is valid when called.
func get_all_audio_streams() -> Array[AudioStream]:
	var results: Array[AudioStream] = []
	
	# Only check for plugin and EditorInterface availability here.
	# get_tree() is guaranteed to be valid at this point because
	# _perform_initial_ui_setup (called by the plugin) waited for it.
	if plugin == null or plugin.get_editor_interface() == null:
		print("DialogEditorUI: Editor plugin or EditorInterface not yet ready, trying again next frame.")
		await get_tree().process_frame # This is now safe as get_tree() is valid.
		return await get_all_audio_streams() # Recursive retry
	
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

func reload_clicked() -> void: # No _async in definition, but contains await
	check_directory()
	play_reload()
	dialog_list.clear()
	audio_selection_list.clear()
	audio = await get_all_audio_streams() # This makes the function asynchronous
	get_all_dialog()

func _ready() -> void:
	# _ready() is now empty. Initial UI setup is triggered externally by the plugin
	# via _perform_initial_ui_setup once the plugin confirms the UI is truly ready.
	pass

# --- NEW: Function called by the plugin to perform initial setup ---
# This is the new entry point for all initial UI setup.
func _perform_initial_ui_setup() -> void:
	print("DialogEditorUI: _perform_initial_ui_setup called by plugin. Proceeding with UI initialization.")
	check_directory()
	await reload_clicked() # Await reload_clicked as it makes an async call

func play_click():
	if click_sound_player!=null and plugin != null and plugin.is_visible:
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
	if save_sound_player!=null and plugin != null and plugin.is_visible:
		save_sound_player.play()

func play_reload():
	if reload_sound_player!=null and plugin != null and plugin.is_visible:
		reload_sound_player.play()

func play_delete():
	if delete_sound_player!=null and plugin != null and plugin.is_visible:
		delete_sound_player.play()

func play_new():
	if new_file_sound_player!=null and plugin != null and plugin.is_visible:
		new_file_sound_player.play()

func save_all() -> void:
	play_save()
	for n in dialog_data:
		ResourceSaver.save(dialog_data[n],dialog_data[n].resource_path)

func save_selected() -> void:
	play_save()
	if dialog_selected_res:
		var save_path = dialog_selected_res.resource_path
		if save_path == "":
			save_path = note_path.path_join(dialog_selected_res.resource_name + ".tres")
		var err := ResourceSaver.save(dialog_selected_res, save_path)
		if err != OK:
			push_error("Failed to save note. Error code: %d" % err)
		dialog_selected_res.emit_changed()

func delete_selected() -> void:
	play_delete()
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
	line_preview_player.stop()
	if dialog_selected_res:
		dialog_page_index -= 1
		clamp_page_index()
		update_page_counter()
		set_data()

func on_page_delete() -> void:
	line_preview_player.stop()
	play_delete()
	if dialog_selected_res:
		dialog_selected_res.remove_page(dialog_page_index)
		check_page()
		if dialog_page_index != 0 and dialog_page_index > dialog_selected_res.lines.size() - 1:
			dialog_page_index -= 1
		set_data()
		update_page_counter()

func on_add_page() -> void:
	line_preview_player.stop()
	play_new()
	if dialog_selected_res:
		dialog_selected_res.add_page()
		dialog_page_index+=1
		set_data()
		update_page_counter()

func on_page_right() -> void:
	line_preview_player.stop()
	play_click()
	if dialog_selected_res:
		dialog_page_index += 1
		clamp_page_index()
		update_page_counter()
		set_data()

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
			dialog += get_all_dialog(full_path) # Recurse
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
		set_bus_from_res()
		update_page_counter()
		checkButton.button_pressed = dialog_selected_res.use_position[dialog_page_index]
	else:
		clear_data()
	pass

func set_bus_from_res():
	print("set bus")
	if dialog_selected_res!=null:
		if dialog_selected_res.audio != null:
			var bus = dialog_selected_res.bus[dialog_page_index]
			bus_selection.select(bus)
			print("bus was set")

func set_bus_from_list(index : int):
	line_preview_player.stop()
	if dialog_selected_res!=null:
		if dialog_selected_res.audio != null:
			dialog_selected_res.bus[dialog_page_index] = bus_selection.selected

func clear_data():
	update_page_counter()
	flags_text.text = ""
	checkButton.button_pressed=false
	text_entry.text = ""
	pass

func check_page():
	if dialog_selected_res !=null:
		if dialog_selected_res.lines.size() == 0 or dialog_selected_res.lines == null:
			dialog_selected_res.add_page()

func update_page_counter():
	if dialog_selected_res != null:
		var index_counter : String = str(dialog_page_index + 1)
		var max_index : String = str(dialog_selected_res.lines.size())
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
	else:
		text_entry.text = ""

func set_res_audio(index : int):
	line_preview_player.stop()
	if dialog_selected_res:
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
	else:
		flags_text.text = ""


func check_button_toggle(toggled_on: bool) -> void:
	if dialog_selected_res:
		dialog_selected_res.use_position[dialog_page_index] = toggled_on

func int_to_audio_bus(bus_index : int) -> Audio.audio_bus:
	var bus : Audio.audio_bus = bus_index
	return bus

func start_music():
	var playlist : editor_playlist = load("res://addons/playlist.tres")
	if music_player and not music_playing: # Use 'not' for clarity, equivalent to '!'.
		var r : RandomNumberGenerator = RandomNumberGenerator.new()
		r.randomize()
		var track = playlist.songs[r.randi_range(0,playlist.songs.size()-1)]
		music_player.stream=track
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


func play_button_clicked() -> void:
	if audio_selection_list.selected == -1:
		print("exiting early, no selection made")
		return
	var selection = audio_selection_list.selected
	if selection >= audio.size():
		print("exiting early, selecgtion out of bounds")
		return
	var bus = bus_selection.selected
	if bus == -1 or bus >= Audio.audio_bus.size():
		print("exiting early, bus selection bad")
		return
	var a_bus : String =  AudioServer.get_bus_name(bus)
	line_preview_player.stop()
	line_preview_player.stream = audio[selection]
	line_preview_player.bus = a_bus
	line_preview_player.play()
	pass # Replace with function body.


func stop_button_pressed() -> void:
	line_preview_player.stop()
	pass # Replace with function body.


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
	line_preview_player.stop()
	if dialog_selected_res:
		dialog_page_index = dialog_selected_res.lines.size()-1
		clamp_page_index()
		update_page_counter()
		set_data()


func first_page_button_pressed() -> void:
	play_click()
	line_preview_player.stop()
	if dialog_selected_res:
		dialog_page_index = 0
		clamp_page_index()
		update_page_counter()
		set_data()
