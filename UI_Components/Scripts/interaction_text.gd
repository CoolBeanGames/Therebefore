extends CanvasLayer
class_name interaction_text

@export var text : Label

func _ready() -> void:
	GameData.references["interaction_text"] = text
