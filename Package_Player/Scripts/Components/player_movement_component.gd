extends Node
class_name player_movement

var input : Vector2
@export var walk_speed : float
@export var gravity_speed : float = - 9.7
@export var body : CharacterBody3D
@export var delta : float

# --- Footstep Variables ---
@export var footstep_sounds: Array[AudioStream] # Array to hold your footstep audio files
@export var footstep_interval: float = 0.3 # Time between footsteps in seconds
var footstep_timer: float = 0.0

func _process(_delta: float) -> void:
	if !GameData.is_input_locked():
		delta = _delta
		update_input()
		set_velocity()
		move_player()
		
		# --- Footstep Logic ---
		handle_footsteps()

func update_input():
	input = Input.get_vector("left","right","back","forward")

func set_velocity():
	var forward = input.y * walk_speed * delta * -body.basis.z
	var side = input.x * walk_speed * delta * body.basis.x
	var grav = gravity_speed  * Vector3(0,1,0)
	body.velocity = forward + side + grav

func move_player():
	body.move_and_slide()


func handle_footsteps():
	var is_moving_horizontally = body.velocity.length() > 0.1 and body.velocity.x != 0 or body.velocity.z != 0
	# Alternatively, check input directly: var is_moving_horizontally = input.length() > 0.1

	if body.is_on_floor() and is_moving_horizontally:
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			play_footstep_sound()
			footstep_timer = 0.0 # Reset timer
	else:
		footstep_timer = 0.0 # Reset timer if not moving or not on floor

func play_footstep_sound():
	if footstep_sounds.size() == 0:
		return 

	var random_index = randi() % footstep_sounds.size()
	var footstep_clip = footstep_sounds[random_index]

	Audio.play(footstep_clip, true, _audio.audio_bus.reverbSFX, true, body.global_position)
	print("Playing footstep sound!")
