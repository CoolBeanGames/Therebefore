extends RichTextLabel
class_name auto_size_rich_text_label

func _ready() -> void:
	await get_tree().process_frame
	var game_base = References.get_reference("game") as game
	game_base.screen_resized.connect(on_screen_resized)
	update_font_size()

func update_font_size():
	var game_base = References.get_reference("game") as game
	var font_size : int = game_base.get_font_size()
	add_theme_font_size_override("normal_font_size",font_size)
	add_theme_font_size_override("bold_font_size",font_size)
	add_theme_font_size_override("bold_italics_font_size",font_size)
	add_theme_font_size_override("italics_font_size",font_size)
	add_theme_font_size_override("mono_font_size",font_size)

func free() -> void:
	var game_base = References.get_reference("game") as game
	game_base.screen_resized.disconnect(on_screen_resized)


func on_screen_resized():
	update_font_size()
