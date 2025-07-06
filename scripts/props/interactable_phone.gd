extends Node3D
class_name interactable_phone

@export var dialog : dialog_res

func _on_interactable_interacted() -> void:
	var ui : game_hud = References.get_reference("ui") as game_hud
	var dialogUI : dialog_ui = ui.dialogUI
	dialogUI.start_dialog(dialog,global_transform.origin)
	pass # Replace with function body.
