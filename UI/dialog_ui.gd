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

@export var current_position : Vector3

signal dialog_finished

func _ready() -> void:
	#set class names for debugging
	idle_state.cls = "idle"
	load_state.cls = "load"
	next_state.cls = "next"
	end_state.cls = "end"
	await get_tree().process_frame
	current_state = idle_state
	current_state.enter_state()

func _process(delta: float) -> void:
	current_state.process() 

func start_dialog(dialog : dialog_res, position : Vector3 = Vector3.ZERO):
	if current_state == idle_state:
		current_dialog = dialog
		current_state.next_state(load_state)
		print("Dialog loaded")
		current_state.next_state(next_state)
	else:
		push_error("tried to start dialog when one was already running")
