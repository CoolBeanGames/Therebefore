extends Node
class_name player_movement

var input : Vector2
@export var walk_speed : float
@export var gravity_speed : float = - 9.7
@export var body : CharacterBody3D
@export var delta : float

func _process(_delta: float) -> void:
	if !GameData.is_input_locked():
		delta = _delta
		update_input()
		set_velocity()
		move_player()

func update_input():
	input = Input.get_vector("left","right","back","forward")

func set_velocity():
	var forward = input.y * walk_speed * delta * -body.basis.z
	var side = input.x * walk_speed * delta * body.basis.x
	var grav = gravity_speed * delta * Vector3(0,1,0)
	body.velocity = forward + side + grav

func move_player():
	body.move_and_slide()
