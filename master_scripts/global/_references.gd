extends Node
class_name _references

@export var refs : Dictionary[String,Node]

func add_reference(node : Node):
	refs[node.name] = node

func add_custom(key : String, node : Node):
	refs[key] = node

func remove_custom(key : String):
	refs.erase(key)

func remove_reference(node : Node):
	refs.erase(node.name)

func get_reference(key : String):
	if has_key(key):
		return refs[key]
	else:
		push_error("ERROR: Key does not exist!, Key : ",key)
		return null

func has_key(key : String):
	return refs.has(key)
