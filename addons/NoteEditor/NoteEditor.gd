@tool
extends EditorPlugin


const MainPanel = preload("res://addons/NoteEditor/NoteEditorUI.tscn")
var main_panel_instance : note_editor
@export var is_visible : bool = false

func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.setup(self)
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if main_panel_instance:
		# Ensure it's parented to EditorInterface.get_editor_main_screen() before removing.
		if main_panel_instance.get_parent() == EditorInterface.get_editor_main_screen():
			EditorInterface.get_editor_main_screen().remove_child(main_panel_instance)
		main_panel_instance.queue_free()
		main_panel_instance = null # Clear the reference


func _has_main_screen():
	return true


func _make_visible(visible_state: bool): # Renamed 'visible' to 'visible_state' to avoid shadowing built-in 'visible' property
	# Godot calls this when your plugin's tab is selected (visible = true) or deselected (visible = false).
	if main_panel_instance:
		main_panel_instance.visible = visible_state
		is_visible = visible_state # Update the plugin's internal state
		
		# Pass the current 'visible_state' directly to the UI script's toggle_music function
		main_panel_instance.toggle_music(visible_state)


func _get_plugin_name():
	return "Note Editor"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
