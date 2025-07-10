extends Node
class_name camera_control

@export var body : Node3D
@export var head : Camera3D
@export var input_vector : Vector2
@export var look_speed : float = 10
@export var pitch : float = 0
@export var pivot : float = 0
@export var delta : float  = 0
@export_category("Camera FOV settings")
@export var fov_zoomed : int = 35
@export var fov_normal : int = 75
@export var fov_speed : float = 10
@export var goal_fov : int = 75
@export var zoom_in_sound : AudioStream
@export var zoom_out_sound : AudioStream


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	InputEvents.mouseMotion.connect(on_mouse_motion)
	goal_fov = fov_normal
	InputEvents.rightMouseDown.connect(on_rmb_down)
	InputEvents.rightMouseUp.connect(on_rmb_up)

func on_mouse_motion(relative) -> void:
	if Input.get_mouse_mode() and !GameData.is_input_locked():
		input_vector = relative
		do_look()

func _process(_delta: float) -> void:
	delta = _delta
	if !GameData.is_input_locked():
		head.fov = lerp(head.fov,float(goal_fov),fov_speed * delta)

func do_look():
	calculate_rot()
	apply_rot()

func on_rmb_up():
	goal_fov = fov_normal
	if !GameData.is_input_locked():
		Audio.play(zoom_out_sound,false,_audio.audio_bus.sfx,false)

func on_rmb_down():
	goal_fov = fov_zoomed
	if !GameData.is_input_locked():
		Audio.play(zoom_in_sound,false,_audio.audio_bus.sfx,false)

func calculate_rot():
	pitch += input_vector.y * look_speed * delta
	pivot += input_vector.x * -look_speed * delta
	
	pitch = clamp(pitch,-90,90)

func apply_rot():
	body.rotation_degrees = Vector3(0,pivot,0)
	head.rotation_degrees = Vector3(pitch,0,0)
