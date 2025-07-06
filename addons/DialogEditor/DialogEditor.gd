# dialog_editor_plugin.gd

@tool
extends EditorPlugin
class_name dialog_editor_plugin

const MainPanel = preload("res://addons/DialogEditor/DialogEditorUI.tscn")
var main_panel_instance : dialog_editor # Type hint for clarity
@export var is_visible : bool = false

var _deferred_ui_init_retries = 0
const _MAX_UI_INIT_RETRIES = 60 # Max retries to prevent infinite loops (e.g., 1 second at 60 FPS)

func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.setup(self) # Pass the plugin instance to the UI early

	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

	# --- CRITICAL CHANGE: Plugin-managed deferred setup ---
	# The plugin itself (which is a stable object) defers calling a helper.
	# This helper will repeatedly check if the UI is fully in the tree.
	call_deferred("_init_ui_when_ready")


func _exit_tree():
	if main_panel_instance:
		# Ensure it's parented to EditorInterface.get_editor_main_screen() before removing.
		# This check prevents errors if the parent changed or it's already removed.
		if main_panel_instance.get_parent() == EditorInterface.get_editor_main_screen():
			EditorInterface.get_editor_main_screen().remove_child(main_panel_instance)
		main_panel_instance.queue_free()
		main_panel_instance = null
	
	_deferred_ui_init_retries = 0 # Reset retry counter on exit


# This async helper function is called by the plugin itself to wait for the UI to be ready.
func _init_ui_when_ready():
	# Check if the UI node instance is valid AND is inside the tree AND has a valid scene tree.
	# The 'and main_panel_instance.is_inside_tree()' is the key to ensure it's attached.
	if main_panel_instance != null and main_panel_instance.is_inside_tree() and main_panel_instance.get_tree() != null:
		# Success! The UI is ready. Trigger its actual setup function.
		print("DialogEditorPlugin: UI instance is fully ready, triggering initial setup.")
		_deferred_ui_init_retries = 0 # Reset retry counter on success
		main_panel_instance._perform_initial_ui_setup() # Call the designated setup function on the UI
	else:
		# Not ready yet, increment retry counter and defer this helper again.
		_deferred_ui_init_retries += 1
		if _deferred_ui_init_retries < _MAX_UI_INIT_RETRIES:
			print("DialogEditorPlugin: UI not fully ready (is_inside_tree() or get_tree() is false). Retrying... (", _deferred_ui_init_retries, "/", _MAX_UI_INIT_RETRIES, ")")
			call_deferred("_init_ui_when_ready") # Plugin defers its own retry
		else:
			printerr("DialogEditorPlugin: Max retries exceeded for UI initialization. Plugin UI might not function correctly.")


func _has_main_screen():
	return true


func _make_visible(visible_state: bool):
	# Godot calls this when your plugin's tab is selected (visible = true) or deselected (visible = false).
	if main_panel_instance:
		main_panel_instance.visible = visible_state
		is_visible = visible_state # Update the plugin's internal state
		
		# Pass the current 'visible_state' directly to the UI script's toggle_music function
		main_panel_instance.toggle_music(visible_state)


func _get_plugin_name():
	return "Dialog Editor"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
