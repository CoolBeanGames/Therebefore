extends Node
class_name game_data

#input locking
var input_paused : bool = false
var input_lockers : Dictionary    #a list of objects that have caused the input to be locked

#game data
@export var references : Dictionary
@export var flags : Dictionary
@export var data : Dictionary

func is_input_locked() -> bool:
	return input_paused

func lock_input(locking_object : Node):
	input_lockers[locking_object.name] = locking_object
	input_paused = true

func unlock_input(locking_object : Node) -> bool:
	if !input_lockers.has(locking_object.name):
		return input_paused         #no effect
	#do the actual unpausing
	input_lockers.erase(locking_object.name)
	if input_lockers.size() == 0:
		input_paused=false
	return input_paused

func set_flag(flag : String):
	flags[flag] = true

func unset_flag(flag : String):
	if flags.has(flag):
		flags.erase(flag)

func read_flag(flag : String) -> bool:
	if flags.has(flag) and flags[flag]==true:
		return true
	return false
