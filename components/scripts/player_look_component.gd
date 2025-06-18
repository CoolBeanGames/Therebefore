extends Node

#references
@export var player_body : CharacterBody3D
@export var player_camera : Camera3D

#values
@export var input : Vector2
@export var look_speed : float = 100
@export var invert_y : bool = false
@export var mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CONFINED_HIDDEN

#private values
var rot_x : float = 0 #pitch
var rot_y : float = 0 #yaw
var delta : float = 0

#signals
signal camera_moved

func _ready() -> void:
	Input.mouse_mode = mouse_mode

func _process(_delta: float) -> void:
	delta = _delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !GameData.is_input_locked():
		input = event.screen_relative
		_update_rot()
		_clamp_y()
		_apply_rot()
		camera_moved.emit()

func _update_rot():
	rot_x += input.y * (look_speed * delta)
	var inversion : int = 1
	if invert_y:
		inversion = -1
	rot_y += (input.x * inversion) * (look_speed * delta)

func _apply_rot():
	player_body.rotation_degrees = Vector3(0,rot_y,0)
	player_camera.rotation_degrees = Vector3(rot_x,0,0)

func _clamp_y():
	rot_x = clamp(rot_x,-90,90)
