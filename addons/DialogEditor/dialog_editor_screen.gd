@tool
extends Control
class_name DialogEditorUI

#consts
const group_path : String = "res://Data/AudioGroups/"
const audio_path : String = "res://Data/Audio/"

#data
@export_category("references")
@export var new_group_name : LineEdit
@export var new_line_name : LineEdit

@export_category("data fields")
@export var audio_contrainer_node : Node
@export var audio_picker : EditorResourcePicker
@export var line_text : TextEdit
@export var bus_field : OptionButton
@export var check_box : CheckBox

#groups
@export_category("Groups Data")
@export var groups : Dictionary[String , subtitled_audio_group]
@export var group_item_list : ItemList
@export var group_selected_string : String
@export var group_selected_index : int
@export var group_selected_res : subtitled_audio_group

#lines
@export_category("Lines Data")
@export var lines : Dictionary[String,subtitled_audio]
@export var line_item_list : ItemList
@export var line_selected_string : String
@export var line_selected_index : int
@export var line_selected_res : subtitled_audio

#private stuff
var parent_plugin : EditorPlugin

func setup(plugin : EditorPlugin):
	parent_plugin = plugin
	check_directory()
	load_all_groups()
	
	#setup the audio file picker
	audio_picker = EditorResourcePicker.new()
	audio_picker.base_type = "AudioStream"
	audio_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio_contrainer_node.add_child(audio_picker)
	audio_picker.resource_changed.connect(on_audio_resource_changed)
	
	#populate the audio bus
	populate_bus()

func reload_all():
	check_directory()
	clear_group_selection()
	clear_line_selection()
	remove_all_lines()
	load_all_groups()

func refresh_resource_database():
	parent_plugin.get_editor_interface().get_resource_filesystem().scan()

func load_all_groups():
	var dir = DirAccess.open(group_path)

	if !dir:
		printerr("ERROR: Could not open groups directory")
		return
	dir.list_dir_begin()
	groups.clear()
	group_item_list.clear()
	
	#process all the files
	var filename = dir.get_next()
	
	while filename:
		print("processing ", filename)
		if filename.ends_with(".tres"):
			var path = group_path.path_join(filename)
			var res = ResourceLoader.load(path)
			if res:
				print("loaded resource " , res.resource_path)
				groups[res.resource_name] = res
				#add the res to the list
				group_item_list.add_item(res.resource_name)
		filename = dir.get_next()
		#add 
	
	dir.list_dir_end()
	pass

#checks that directories exist and if not, create them
func check_directory():
	if !DirAccess.dir_exists_absolute(group_path):
		DirAccess.make_dir_absolute(group_path)
	if !DirAccess.dir_exists_absolute(audio_path):
		DirAccess.make_dir_absolute(audio_path)
	refresh_resource_database()

func group_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	clear_group_selection()
	clear_line_selection()

func group_selected(index: int) -> void:
	group_selected_index = index
	group_selected_string = group_item_list.get_item_text(index)
	group_selected_res = groups[group_selected_string]
	remove_all_lines()
	load_all_lines()

func clear_group_selection():
	group_selected_index = -1
	group_selected_res = null
	group_selected_string = ""
	group_item_list.deselect_all()
	remove_all_lines()

func line_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	clear_line_selection()

func line_selected(index: int) -> void:
	reset_all_data()
	line_selected_index = index
	line_selected_string = line_item_list.get_item_text(index)
	line_selected_res = lines[line_selected_string]
	set_all_data()

func add_new_group() -> void:
	var group_name : String = new_group_name.text
	var group : subtitled_audio_group = subtitled_audio_group.new()
	group.resource_name = group_name
	
	var path = group_path.path_join(group_name + ".tres")
	group.resource_path = path
	ResourceSaver.save(group,path)
	groups[group_name] = group
	group_item_list.add_item(group_name)
	refresh_resource_database()
	
	new_group_name.text=""

func add_new_line() -> void:
	var dir = DirAccess.open(audio_path)
	
	if group_selected_res != null and dir and new_line_name.text != "" and !dir.file_exists(new_line_name.text + ".tres"):
		var line_name : String = new_line_name.text
		var line : subtitled_audio = subtitled_audio.new()
		line.resource_name = line_name
		
		var path = audio_path.path_join(line_name + ".tres")
		line.resource_path=path
		ResourceSaver.save(line,path)
		lines[line_name] = line
		line_item_list.add_item(line_name)
		
		#save the group
		group_selected_res.lines.append(line)
		ResourceSaver.save(group_selected_res,group_selected_res.resource_path)
		refresh_resource_database()
		
		new_line_name.text = ""

func load_all_lines() -> void:
	lines.clear()
	line_selected_index = -1
	line_selected_res = null
	line_selected_string = ""
	line_item_list.deselect_all()
	line_item_list.clear()
	#clear data fields here
	if group_selected_res!=null:
		for l in group_selected_res.lines:
			lines[l.resource_name] = l
			line_item_list.add_item(l.resource_name)

func on_audio_resource_changed(res : Resource):
	if line_selected_res != null and res is AudioStream:
		line_selected_res.Audio = res
		save_line()

func text_updated() -> void:
	if line_selected_res != null:
		line_selected_res.Text = line_text.text
		save_line() 

func save_line():
	if line_selected_res != null:
		ResourceSaver.save(line_selected_res,line_selected_res.resource_path)

func save_line_other(line : subtitled_audio):
	if line != null:
		ResourceSaver.save(line,line.resource_path)

func clear_line_selection():
	line_selected_index = -1
	line_selected_res = null
	line_selected_string = ""
	line_item_list.deselect_all()
	reset_all_data()

func bus_changed(index: int) -> void:
	if line_selected_res!=null:
		print("found bus index ", index)
		print("it corresponds to: ", bus_field.get_item_text(index))
		print("this gives me the key:",AudioManager.audio_bus.find_key(index))
		var bus : AudioManager.audio_bus = index
		line_selected_res.Bus = bus

func populate_bus():
	bus_field.clear()
	for k in AudioManager.audio_bus.keys():
		bus_field.add_item(k)

func checkbox_changed(toggled_on: bool) -> void:
	if line_selected_res != null:
		line_selected_res.skip_position = toggled_on

func set_all_data():
	if line_selected_res != null:
		print("attempted to set line")
		audio_picker.edited_resource = line_selected_res.Audio
		
		print("attempting to set text")
		line_text.text = line_selected_res.Text
		
		print("setting selected bus")
		var index : int = line_selected_res.Bus
		bus_field.select(index)
		
		print("setting check")
		check_box.button_pressed = line_selected_res.skip_position

func reset_all_data():
	audio_picker.edited_resource = null
	line_text.text = ""
	bus_field.select(0)
	check_box.button_pressed = false

func remove_all_lines():
	clear_line_selection()
	lines.clear()
	line_item_list.clear()

func delete_selected() -> void:
	print("Delete")
	refresh_resource_database()
	if line_selected_res != null:
		var res_path = line_selected_res.resource_path
		print(res_path)
		#get the director and file
		var directory = res_path.get_base_dir()
		var file = res_path.get_file()
		
		#open dir
		var dir = DirAccess.open(directory)
		if dir:
			print("dir is open at ", directory)
			var error = dir.remove(res_path)
			if error == OK and !dir.file_exists(file):
				print("file successfully deleted")
				group_selected_res.lines.erase(line_selected_res)
				clear_line_selection()
				load_all_lines()
	else:
		#now we clear a whole ass group
		if group_selected_res!=null:
			var res_path = group_selected_res.resource_path
			print(res_path)
			#get the director and file
			var directory = res_path.get_base_dir()
			var file = res_path.get_file()
			var resource_name = group_selected_string
			
			#open dir
			var dir = DirAccess.open(directory)
			if dir:
				print("dir is open at ", directory)
				var error = dir.remove(res_path)
				if error == OK and !dir.file_exists(file):
					print("file successfully deleted")
					groups.erase(resource_name)
					reload_all()
					remove_all_lines()

func save_group():
	if group_selected_res!=null:
		ResourceSaver.save(group_selected_res,group_selected_res.resource_path)

func save_group_other(group : subtitled_audio_group):
	if group!=null:
		ResourceSaver.save(group,group.resource_path)

func save_all() -> void:
	for g in groups:
		for l in groups[g].lines:
			save_line_other(groups[g].lines[l])
		save_group_other(groups[g])
	print("saved all data")

func enter_pressed_on_group_name(new_text: String) -> void:
	add_new_group()

func enter_pressed_on_line_name(new_text: String) -> void:
	add_new_line()

func move_line_up() -> void:
	if line_selected_index != -1 and line_selected_index != 0:
		#the line is valid and is not the first
		var line = line_selected_res
		var index = line_selected_index
		group_selected_res.lines.remove_at(index)
		group_selected_res.lines.insert(index -1,line)
		load_all_lines()
		line_item_list.select(index-1)
		line_selected(index-1)

func move_line_down() -> void:
	if line_selected_index != -1 and line_selected_index != lines.size()-1:
		var line = line_selected_res
		var index = line_selected_index
		
		group_selected_res.lines.insert(index + 2,line)
		group_selected_res.lines.remove_at(index)
		
		load_all_lines()
		line_item_list.select(index + 1)
		line_selected(index + 1)
		pass # Replace with function body.
