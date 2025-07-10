extends Node
class_name input_events

signal mouseMotion
signal mouseWheelUp
signal mouseWheelDown
signal rightMouseDown
signal rightMouseUp

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseMotion.emit(event.relative)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			mouseWheelUp.emit()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			mouseWheelDown.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				rightMouseDown.emit()
			else:
				rightMouseUp.emit()
