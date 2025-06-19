@tool
extends Control
class_name DialogEditorUI

#consts
const group_path : String = "res://Data/AudioGroups/"
const audio_path : String = "res://Data/Audio/"

#data
@export var groups : Dictionary[String , subtitled_audio_group]

#references
@export var groups_item_list : ItemList

#private stuff
var parent_plugin : EditorPlugin

func setup(plugin : EditorPlugin):
	parent_plugin = plugin
	check_directory()
	load_all_groups()
	pass

func refresh_resource_database():
	parent_plugin.get_editor_interface().get_resource_filesystem().scan()

func load_all_groups():
	var dir = DirAccess.open(group_path)

	if !dir:
		printerr("ERROR: Could not open groups directory")
		return
	dir.list_dir_begin()
	groups.clear()
	groups_item_list.clear()
	
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
				groups_item_list.add_item(res.resource_name)
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
