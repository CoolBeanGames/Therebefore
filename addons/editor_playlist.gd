@tool
extends Resource
class_name editor_playlist

@export var songs : Array[AudioStream]
var random_set : bool = false
var random : RandomNumberGenerator = RandomNumberGenerator.new()

func get_track() -> AudioStream:
	if !random_set:
		random_set = true
		random.randomize()
	var stream = songs[random.randi_range(0,songs.size()-1)]
	print("playing: ", stream.resource_name)
	return stream
