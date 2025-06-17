extends CanvasLayer
class_name subtitle_display

@export var subtitle : Label

func _ready() -> void:
	GameData.references["subtitles"] = subtitle
