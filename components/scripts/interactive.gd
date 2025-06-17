extends StaticBody3D
class_name interactive

#references
@export var parent : Node
@export var interact_text : Label

#values
@export var display_text : String = ""

signal on_start_looking
signal on_stop_looking
signal on_interact
 
func _ready() -> void:
	await get_tree().process_frame
	interact_text = GameData.references["interaction_text"]

func start_looking():
	interact_text.text = display_text
	on_start_looking.emit()

func stop_looking():
	interact_text.text = ""
	on_stop_looking.emit()

func interact():
	on_interact.emit()
