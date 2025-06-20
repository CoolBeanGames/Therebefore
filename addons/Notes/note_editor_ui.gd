@tool
extends Control
class_name NoteEditorUI

const note_path = ("res://Data/Notes/")

var parent_plugin : EditorPlugin
@export var notes : Dictionary[String,Note]
@export var note_item_list : ItemList

@export_category("references")
@export var preview_texture : TextureRect
@export var new_note_text : LineEdit

@export_category("note selection")
@export var note_selected_index : int = -1
@export var note_selected_string : String = ""
@export var note_selected_res : Note

@export_category("data references")
@export var image_picker_parent : Node
@export var image_picker : EditorResourcePicker
@export var note_text : TextEdit
@export var audio_contrainer_node : Node
@export var audio_picker : EditorResourcePicker
@export var use_audio : CheckBox



func setup(plugin : EditorPlugin):
	parent_plugin = plugin
	check_directory()
	
	#setup image picker
	image_picker = EditorResourcePicker.new()
	image_picker.base_type = "Texture"
	image_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	image_picker_parent.add_child(image_picker)
	image_picker.resource_changed.connect(on_image_changed)
	
	#setup audio picker
	audio_picker = EditorResourcePicker.new()
	audio_picker.base_type = "AudioStream"
	audio_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio_contrainer_node.add_child(audio_picker)
	audio_picker.resource_changed.connect(on_audio_resource_changed)
	
	load_all_notes()


func refresh_resource_database():
	parent_plugin.get_editor_interface().get_resource_filesystem().scan()

func load_all_notes():
	var dir = DirAccess.open(note_path)

	if !dir:
		printerr("ERROR: Could not open notes directory")
		return
	dir.list_dir_begin()
	notes.clear()
	notes.clear()
	
	#process all the files
	var filename = dir.get_next()
	
	while filename:
		print("processing ", filename)
		if filename.ends_with(".tres"):
			var path = note_path.path_join(filename)
			var res = ResourceLoader.load(path)
			if res:
				print("loaded resource " , res.resource_path)
				notes[res.resource_name] = res
				#add the res to the list
				note_item_list.add_item(res.resource_name)
		filename = dir.get_next()
		#add 
	
	dir.list_dir_end()
	pass

func on_image_changed(resource : Resource):
	if resource!=null and resource is Texture:
		preview_texture.texture = resource
		if note_selected_res!=null:
			note_selected_res.note_texture = resource
			save_note(note_selected_res)


func add_new_note() -> void:
	var note_name : String = new_note_text.text
	var note : Note = Note.new()
	note.resource_name = note_name
	
	var path = note_path.path_join(note_name + ".tres")
	note.resource_path = path
	ResourceSaver.save(note,path)
	notes[note_name] = note
	note_item_list.add_item(note_name)
	refresh_resource_database()
	
	new_note_text.text=""
	refresh_resource_database()


func add_new_note_enter_pressed(new_text: String) -> void:
	add_new_note()

func check_directory():
	if !DirAccess.dir_exists_absolute(note_path):
		DirAccess.make_dir_absolute(note_path)
		print("Made new note directory")
		refresh_resource_database()


func note_selected(index: int) -> void:
	note_selected_index = index
	note_selected_string = notes.keys()[index]
	note_selected_res = notes[note_selected_string]
	print(note_selected_res.resource_name)
	read_all_data()


func clear_selection(at_position: Vector2, mouse_button_index: int) -> void:
	_deselect()

func _deselect():
	note_item_list.deselect_all()
	note_selected_index = -1
	note_selected_res = null
	note_selected_string = ""
	clear_all_data()

func clear_all_data():
	image_picker.edited_resource = null
	preview_texture.texture = null
	audio_picker.edited_resource = null
	note_text.text = ""
	use_audio.button_pressed = false

func read_all_data():
	var note : Note = note_selected_res
	image_picker.edited_resource = note.note_texture
	preview_texture.texture = note.note_texture
	audio_picker.edited_resource = note.audio
	note_text.text = note.note_text
	use_audio.button_pressed = note.play_audio

func save_note(note : Note):
	if note!=null:
		ResourceSaver.save(note,note.resource_path)

func reload() -> void:
	_deselect()
	load_all_notes()

func on_audio_resource_changed(resource : Resource):
	if note_selected_res!=null:
		note_selected_res.audio = resource
		save_note(note_selected_res)


func checkbox_pressed(toggled_on: bool) -> void:
	if note_selected_res!=null:
		note_selected_res.play_audio=toggled_on
		save_note(note_selected_res)


func texted_edited() -> void:
	if note_selected_res!=null:
		note_selected_res.note_text = note_text.text
		save_note(note_selected_res)
