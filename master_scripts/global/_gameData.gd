extends Node
class_name game_data

var input_locked : bool = false
var input_lockers : Array[Node]

@export var playerSettings : PlayerSettings
@export var flags : Array[String]

func _ready() -> void:
	playerSettings = PlayerSettings.new()
	playerSettings.load_settings()
	print("player settings invert y set to ",playerSettings.invert_y)
	InputEvents.mouseInvertPressed.connect(on_invert_y)

func on_invert_y():
	playerSettings.invert_y = !playerSettings.invert_y
	playerSettings.save_settings()

#input locking

func lock_input(node : Node):
	if !input_lockers.has(node):
		input_lockers.append(node)
	process_lock()

func release_input_lock(node : Node):
	if input_lockers.has(node):
		input_lockers.erase(node)
	process_lock()

func is_input_locked() -> bool:
	process_lock()
	return input_locked

func process_lock():
	input_locked = input_lockers.size() > 0

#flags
func set_flag(flag : String):
	if check_flag(flag):
		flags.append(flag)
	else:
		print("tried to set a flag ( ", flag, " ) but flag was already set ")

func set_flags(flag_array : Array[String]):
	for f in flag_array:
		set_flag(f)

func check_flag(flag : String) ->bool:
	return flags.has(flag)

func remove_flag(flag : String):
	if check_flag(flag):
		flags.erase(flag)
