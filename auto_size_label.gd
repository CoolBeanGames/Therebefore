extends Label
class_name auto_size_label

func _ready() -> void:
	await get_tree().process_frame
	var game_base = References.get_reference("game") as game
	game_base.screen_resized.connect(on_screen_resized)
	update_font_size()

func update_font_size():
	var game_base = References.get_reference("game") as game
	var font_size : int = game_base.get_font_size()
	add_theme_font_size_override("font_size",font_size)
	print("Label: ", name, " Set to Font Size ", font_size)


func free() -> void:
	var game_base = References.get_reference("game") as game
	game_base.screen_resized.disconnect(on_screen_resized)

func on_screen_resized():
	update_font_size()
