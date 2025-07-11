extends Node
class_name input_events

signal mouseMotion
signal mouseWheelUp
signal mouseWheelDown
signal rightMouseDown
signal rightMouseUp
signal mouseInvertPressed

func _ready() -> void:
	#add new inputs here
	
	#toggle invert
	if not InputMap.has_action("invert_y"):
		InputMap.add_action("invert_y")
		var event_key = InputEventKey.new()
		event_key.keycode = KEY_I 
		InputMap.action_add_event("invert_y", event_key)

func _process(delta: float) -> void:
	if Input.is_action_just_released("invert_y"):
		print("camera inversion switched")
		mouseInvertPressed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_input : Vector2 = event.relative
		#invert if needed
		if !GameData.playerSettings.invert_y:
			mouse_input.y *= -1
		#send out the event
		mouseMotion.emit(mouse_input)
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
