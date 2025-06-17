extends CharacterBody3D
class_name player

func _ready() -> void:
	GameData.references["player"] = self
