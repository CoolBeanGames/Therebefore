extends Node
class_name game

@export var ActivePlayersParent : Node
@export var InactivePlayersParent : Node

func _ready() -> void:
	References.add_custom("game",self)
