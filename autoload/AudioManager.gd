extends Node
class_name audio_manager

@export var is_initialized : bool = false
@export var Inactive_Parent : Node
@export var Active_Parent : Node
@export var AudioPlayerPrefab : PackedScene
@export var ActivePlayers : Array[AudioPlayer]
@export var InactivePlayers : Array[AudioPlayer]
@export var MaxPlayers : int = 24

func initialize(Inactive_key : String, Active_Key : String):
	Inactive_Parent = GameData.references[Inactive_key]
	Active_Parent = GameData.references[Active_Key]
	is_initialized = true
	
	#initialize the players
	AudioPlayerPrefab= load("res://prefabs/audio_player.tscn")
	spawnPlayers()

func spawnPlayers():
	var index : int = 0
	for i in MaxPlayers:
		var p : AudioPlayer = spawnPlayer(index)
		print("Spawned audio player: " , str(index))
		index += 1

func spawnPlayer(index : int) -> AudioPlayer:
	var name = "Audio Player " + str(index) 
	var player : AudioPlayer = AudioPlayerPrefab.instantiate()
	player.name = name
	Inactive_Parent.add_child(player)
	InactivePlayers.append(player)
	return player

func playSound(clip : AudioStream) -> AudioPlayer:
	if InactivePlayers.size() == 0:
		return null
	#get the first player
	var Audio : AudioPlayer = InactivePlayers[0]
	
	#reparent the player
	InactivePlayers.remove_at(0)
	Inactive_Parent.remove_child(Audio)
	Active_Parent.add_child(Audio)
	ActivePlayers.append(Audio)
	
	#set the clip
	Audio.stream = clip
	Audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	
	#connect stream finished sound
	Audio.stream_finished.connect(pushBack.bind(Audio))
	
	#start playing
	Audio.play()	
	
	return Audio

func playPositionalSound(clip : AudioStream, position : Vector3)-> AudioPlayer:
	if InactivePlayers.size() == 0:
		return null
	#get the first player
	var Audio : AudioPlayer = InactivePlayers[0]
	
	#reparent the player
	InactivePlayers.remove_at(0)
	Inactive_Parent.remove_child(Audio)
	Active_Parent.add_child(Audio)
	ActivePlayers.append(Audio)
	
	#set the clip
	Audio.stream = clip
	Audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	Audio.position = position
	
	#connect stream finished sound
	Audio.stream_finished.connect(pushBack.bind(Audio))
	
	#start playing
	Audio.play()	
	
	return Audio

func pushBack(Audio : AudioPlayer):
	Audio.stop()
	ActivePlayers.erase(Audio)
	Active_Parent.remove_child(Audio)
	Inactive_Parent.add_child(Audio)
	InactivePlayers.append(Audio)
	pass
