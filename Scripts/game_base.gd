extends Node
class_name game_base

@export var inactiveAudioPlayers : Node
@export var activeAudioPlayers : Node

func _ready() -> void:
	GameData.references["inactivePlayers"] = inactiveAudioPlayers
	GameData.references["activePlayers"] = activeAudioPlayers
	AudioManager.initialize("inactivePlayers","activePlayers")
	print("initialize audio manager")
