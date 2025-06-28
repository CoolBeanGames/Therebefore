extends Node
class_name camera_control

@export var body : Node3D
@export var head : Camera3D
@export var input_vector : Vector2
@export var look_speed : float = 10
@export var pitch : float = 0
@export var pivot : float = 0
@export var delta : float  = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode():
		input_vector = event.relative
		do_look()

func _process(_delta: float) -> void:
	delta = _delta

func do_look():
	calculate_rot()
	apply_rot()

func calculate_rot():
	pitch += input_vector.y * look_speed * delta
	pivot += input_vector.x * look_speed * delta
	
	pitch = clamp(pitch,-90,90)

func apply_rot():
	body.rotation_degrees = Vector3(0,pivot,0)
	head.rotation_degrees = Vector3(pitch,0,0)
