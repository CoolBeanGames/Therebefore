extends Node3D
class_name interactable_phone

@export var dialog : dialog_res
@export var pause_when_active : bool = false
var ui : game_hud
var dialogUI : dialog_ui 

func _ready() -> void:
	ui = References.get_reference("ui") as game_hud
	dialogUI = ui.dialogUI

func _on_interactable_interacted() -> void:
	dialogUI.start_dialog(dialog,global_transform.origin)
	dialogUI.dialog_finished.connect(on_dialog_finished)
	
	if pause_when_active:
		GameData.lock_input(self)

func on_dialog_finished():
	dialogUI.dialog_finished.disconnect(on_dialog_finished)
	if pause_when_active:
		GameData.release_input_lock(self)
