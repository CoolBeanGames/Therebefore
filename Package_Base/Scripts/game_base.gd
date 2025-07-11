extends Node
class_name game

@export var ActivePlayersParent : Node
@export var InactivePlayersParent : Node

@export var font_sizes_by_width: Dictionary = {
	640: 22,
	800: 28,
	1024: 32,
	1280: 45,
	1366: 45,
	1440: 50,
	1536: 50,
	1600: 53,
	1920: 64,
	2560: 86,
	3840: 136,
	5120: 178
}
@export var font_size : int = 0
signal screen_resized

func _enter_tree() -> void:
	Audio.prepare()

func _ready():
	References.add_custom("game",self)
	print("game set")
	get_viewport().size_changed.connect(screen_size_changed)
	_update_font_size()

func screen_size_changed():
	_update_font_size()
	screen_resized.emit()

func get_font_size_for_width(current_viewport_width: int) -> int:
	var sorted_widths: Array = font_sizes_by_width.keys()
	sorted_widths.sort()

	# Check for an exact match first
	if font_sizes_by_width.has(current_viewport_width):
		return font_sizes_by_width[current_viewport_width]

	var chosen_width: int = -1 # Initialize with a value that indicates no suitable width found yet

	# Find the largest key that is less than or equal to current_viewport_width
	for width in sorted_widths:
		if current_viewport_width >= width:
			chosen_width = width
		else:
			# Since widths are sorted, if current_viewport_width is less than 'width',
			# we've gone past any suitable larger keys. The last 'chosen_width' is our answer.
			break

	# If a suitable chosen_width was found (i.e., not -1), return its corresponding font size.
	if chosen_width != -1:
		return font_sizes_by_width[chosen_width] # <-- CORRECTED: Return the value for chosen_width
	else:
		# This case means current_viewport_width was smaller than all keys in the dictionary.
		# Return the font size for the smallest available width.
		if !sorted_widths.is_empty():
			return font_sizes_by_width[sorted_widths[0]]
		else:
			# Dictionary is empty, no font sizes defined.
			# You might want to log an error or return a sensible default like 0 or 1.
			print("Warning: font_sizes_by_width dictionary is empty!")
			return -1 # Indicate failure or no valid font size

func _update_font_size():
	var current_viewport_width = get_viewport().get_visible_rect().size.x
	font_size = get_font_size_for_width(int(current_viewport_width)) # Ensure it's an integer
	print("font size set to: ", font_size, " for a width of : ", current_viewport_width)

func get_font_size() -> int:
	_update_font_size()
	return font_size
