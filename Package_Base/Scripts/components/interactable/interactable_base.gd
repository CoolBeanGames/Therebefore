extends StaticBody3D
class_name interactable

@export var look_at_text : String = "[E] to interact"
signal started_looking
signal stopped_looking
signal interacted
@export var flags : Array[String]
var flags_set : bool = false
var is_look_at : bool = false
var ui : game_hud

func _ready() -> void:
	if get_parent():
		get_parent().add_to_group("interactable")
	await get_tree().process_frame
	ui = References.get_reference("ui")

func start_looking_at():
	started_looking.emit()
	is_look_at = true
	ui.interaction_text.update_font_size()
	ui.set_interaction(look_at_text)
	print("start looking")
	pass

func stop_looking_at():
	stopped_looking.emit()
	is_look_at = false
	print("stop looking")
	pass

func interact():
	print("interact")
	if !flags_set:
		#set flags here
		GameData.set_flags(flags)
		pass
	interacted.emit()
	pass
