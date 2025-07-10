extends Node3D
class_name item_examine

var examining_item : bool = false
@export var parent_to_add_item : Node3D
@export var yaw_node : Node3D
@export var pitch_node : Node3D
var yaw : float = 0
var pitch : float = 0
@export var item : Node3D
@export var input : Vector2
@export var rot_speed : float  = 100
@export var zoom_speed : float = 100
@export var camera : Camera3D
@export var examine_ui : Control
var delta : float = 0

signal finish_examine

func _ready() -> void:
	References.add_custom("item_examine",self)
	await get_tree().process_frame
	await get_tree().process_frame

func start_examine(mesh : PackedScene):
	examining_item = true
	GameData.lock_input(self)
	item = mesh.instantiate()
	parent_to_add_item.add_child(item)
	yaw = 0
	pitch = 0
	InputEvents.mouseWheelUp.connect(on_mouse_wheel_up)
	InputEvents.mouseWheelDown.connect(on_mouse_wheel_down)
	camera.fov = 45
	examine_ui.visible = true

func end_examine():
	examining_item = false
	item.queue_free()
	item = null
	GameData.release_input_lock(self)
	InputEvents.mouseWheelUp.disconnect(on_mouse_wheel_up)
	InputEvents.mouseWheelDown.disconnect(on_mouse_wheel_down)
	examine_ui.visible = false
	finish_examine.emit()

func _process(_delta: float) -> void:
	delta = _delta
	if examining_item:
		input = Input.get_vector("left","right","forward","back")
		rot()
		if Input.is_action_just_released("exit"):
			end_examine()

func rot():
	yaw += rot_speed * input.x * delta
	pitch += rot_speed * input.y * delta
	
	yaw_node.rotation_degrees = Vector3(0,yaw,0)
	pitch_node.rotation_degrees = Vector3(pitch,0,0)

func on_mouse_wheel_up():
	print("Mouse Wheel Up!")
	camera.fov -= zoom_speed * delta
	_clamp_fov()

func on_mouse_wheel_down():
	print("Mouse Wheel Down!")
	camera.fov += zoom_speed * delta
	_clamp_fov()

func _clamp_fov():
	camera.fov = clamp(camera.fov,17,120)
