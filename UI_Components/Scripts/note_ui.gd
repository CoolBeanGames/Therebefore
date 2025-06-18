extends CanvasLayer
class_name note_ui

@export var is_active : bool = false
var text_active : bool = false
var ready_for_input : bool = false

@export_category("references")
@export var darkness_panel : Panel
@export var note_texture : TextureRect
@export var text : Label
@export var Q_prompt : Label
@export var E_prompt : Label
@export var current_note : Note
@export var interaction_timer : Timer
@export var audio_player : AudioPlayer

signal note_closed

func show_note(note : Note):
	print("showing note")
	current_note = note
	show_ui()
	hide_text()
	interaction_timer.start()

func on_timer_finish():
	ready_for_input = true

func _ready() -> void:
	GameData.references["NoteUI"] = self
	hide_text()
	if !is_active:
		hide_ui()

func _process(delta: float) -> void:
	if is_active and ready_for_input:
		if Input.is_action_just_released("interact"):
			if text_active:
				hide_text()
			else:
				show_text()
		if Input.is_action_just_released("cancel"):
			if text_active:
				hide_text()
			else:
				hide_ui()

func show_text():
	print("showing text")
	text_active=true
	text.text = current_note.note_text
	darkness_panel.visible = true
	update_text("hide text","hide text")
	if current_note.play_audio:
		play_audio()

func play_audio():
	audio_player = AudioManager.playSound(current_note.audio,audio_manager.audio_bus.Vocals)

func stop_audio():
	if audio_player!=null:
		audio_player.stop()
		audio_player.stream_finished.emit()
		audio_player=null

func hide_text():
	print("hiding text")
	text_active=false
	text.text = ""
	darkness_panel.visible=false
	stop_audio()
	update_text("show text","close")	


func show_ui():
	print("enabling note ui")
	visible = true
	note_texture.texture = current_note.note_texture
	update_text("show text","close")
	GameData.lock_input(self)
	is_active = true

func hide_ui():
	print("hiding note ui")
	hide_text()
	visible = false
	GameData.unlock_input(self)
	is_active = false
	note_texture.texture = null
	note_closed.emit()
	ready_for_input=false

func update_text(e_key_string : String, q_key_string : String):
	print("updating text")
	E_prompt.text = (e_key_string + "[E]")
	Q_prompt.text = (q_key_string + "[Q]")
