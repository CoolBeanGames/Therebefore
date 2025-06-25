@tool
extends Control
class_name note_editor

var audio_streams : Array[AudioStream]
var textures : Array[Texture2D]
@export var click_sound_player : AudioStreamPlayer
@export var confirm_sound_player : AudioStreamPlayer

func get_all_audio_streams() -> Array[AudioStream]:
	var results : Array[AudioStream]= []
	var fs := EditorInterface.get_resource_filesystem()
	_scan_dir_for_audio(fs.get_filesystem(), results)
	return results

func _scan_dir_for_audio(dir: EditorFileSystemDirectory, results: Array[AudioStream]) -> void:
	for i in dir.get_file_count():
		var path = dir.get_file_path(i)
		var type = dir.get_file_type(i)
		if type.begins_with("AudioStream"):
			var stream = ResourceLoader.load(path)
			if stream != null:
				results.append(stream)
	for i in dir.get_subdir_count():
		_scan_dir_for_audio(dir.get_subdir(i), results)

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

	for i in dir.get_subdir_count():
		_scan_dir_for_textures(dir.get_subdir(i), results)


func reload_clicked() -> void:
	play_click()
	audio_streams = get_all_audio_streams() 
	textures = get_all_textures()
	print("found ", audio_streams.size(), " sound files and ", textures.size(), " textures")
	for t in textures:
		print(t.resource_path)
	pass # Replace with function body.

func play_click():
	if click_sound_player!=null:
		click_sound_player.play(.2)
