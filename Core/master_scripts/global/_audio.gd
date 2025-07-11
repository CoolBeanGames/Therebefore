extends Node
class_name _audio

@export var player_id_counter : int = 0

#references
@export var active_parent : Node
@export var inactive_parent : Node
@export var player_prefab : PackedScene
@export var game_base : game

enum audio_bus{master,sfx,music,vocal,phone,ui,reverbSFX,reverbVocal}

func prepare() -> void:
	await get_tree().process_frame
	game_base = References.get_reference("game")
	active_parent = game_base.ActivePlayersParent
	inactive_parent = game_base.InactivePlayersParent
	player_prefab = load("res://Package_Base/Scenes/prefabs/audio_player.tscn")
	print("audio manager ready")

#pop a player and start it playing
func play(clip : AudioStream,randomize_pitch : bool = false,bus : audio_bus = audio_bus.master, use_position : bool = false, position : Vector3 = Vector3(0,0,0)) -> audio_player:
	var player : audio_player = pop()
	player.start(clip,randomize_pitch,bus,use_position,position)
	player.audio_finished.connect(player_finished)
	return player

#return a finished audio player back to the stack
func push(player : audio_player):
	player.reparent(inactive_parent)
	player.stop()
	player.name = "inactive_audio_player_" + str(player.player_id)

#get a audio player, if one doesnt exist create one otherwise get an inactive one
func pop() -> audio_player:
	var value : audio_player
	if inactive_parent.get_child_count() > 0:
		value = inactive_parent.get_child(0)
		if not (value is audio_player):
			push_error("ERROR: a non audio player was added to the inactive pool")
			push_error("Removing from list and trying again")
			push_error("Offeending Node: ", value.name)
			value.queue_free()
			return pop()
		value.reparent(active_parent)
		value.name = "active_audio_player_" + str(value.player_id)
		print("audio player exists and is inactive so pulling it")
	else:
		value = player_prefab.instantiate()
		value.name = "active_audio_player_" + str(player_id_counter)
		value.player_id = player_id_counter
		player_id_counter += 1
		active_parent.add_child(value)
		print("audio player does NOT exist so making a new one ID:",value.player_id)
	return value

func player_finished(player : audio_player):
	player.audio_finished.disconnect(player_finished.bind(player))
	push(player)
	
