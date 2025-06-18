extends Node
class_name player_movement

#references
@export var player_body : CharacterBody3D

#values 
@export var move_speed : float = 10
@export var gravity : float = -9.7
@export var input : Vector2

#private values
var delta : float = 0

func _ready() -> void:
	GameData.references["player_movement"] = self

func update_input_keyboard():
	input = Input.get_vector("left","right","down","up")

func set_velocity():
	var forward_velocity : Vector3 = -player_body.basis.z * (move_speed * delta * input.y)
	var right_velocity : Vector3 = player_body.basis.x * (move_speed * delta * input.x)
	var downward_velocity : Vector3 = Vector3(0,gravity * delta,0)
	player_body.velocity = forward_velocity + right_velocity + downward_velocity

func move():
	player_body.move_and_slide()

func _process(_delta: float) -> void:
	if !GameData.is_input_locked():
		delta = _delta
		update_input_keyboard()
		if input.length() > 0.1:
			set_velocity()
			move()
