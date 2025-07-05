extends Control
class_name dialog_ui


@export var current_state : dialog_state
@export var idle_state : dialog_idle = dialog_idle.new()
@export var load_state : dialog_load = dialog_load.new()
@export var next_state : dialog_next = dialog_next.new()
@export var end_state : dialog_end = dialog_end.new()

@export var current_dialog : dialog_res
@export var dialog_index : int = 0

@export var text : RichTextLabel
@export var current_audio_player : audio_player

func _ready() -> void:
	await get_tree().process_frame
	current_state = idle_state
	current_state.enter_state()

func _process(delta: float) -> void:
	current_state.process() 

func start_dialog(dialog : dialog_res):
	if current_state == idle_state:
		current_state.next_state(load_state)
		current_state.next_state(next_state)
	else:
		push_error("tried to start dialog when one was already running")
