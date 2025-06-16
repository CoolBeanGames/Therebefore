extends Node

#references
@export var player_body : CharacterBody3D

#values 
@export var move_speed : float = 10
@export var gravity : float = -9.7
@export var input : Vector2

func update_input_keyboard():
	input = Input.get_vector("left","right","down","up")

func update_input_gamepad():
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		update_input_keyboard()
		set_velocity()
		move()
	if event is InputEventJoypadMotion:
		update_input_gamepad()
		set_velocity()
		move()

func set_velocity():
	var forward_velocity : Vector3
	var right_velocity : Vector3
	var downward_velocity : Vector3
	player_body.velocity = forward_velocity + right_velocity + downward_velocity

func move():
	player_body.move_and_slide()
