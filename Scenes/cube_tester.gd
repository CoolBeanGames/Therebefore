extends CSGBox3D

var state : int = 0
@export var mats : Array[Material]
@export var lig : OmniLight3D
@export var AudioClip : AudioStream
@export var Audio : AudioPlayer

func _ready() -> void:
	set_mat(mats[0])
	lig.light_energy = 0

func _on_interactive_on_interact() -> void:
	print("interacted with the cube")
	state += 1
	if state > 1:
		state = 0
	set_mat(mats[state])
	lig.light_energy = 2 * state
	print(state)
	SubtitledAudioPlayer.start_playing_positional(load("res://Data/AudioGroups/conv ersation.tres"),position)

func AudioFinished():
	Audio = null

func _process(delta: float) -> void:
	if state == 1:
		rotate_y(delta * 10)

func set_mat(mat : Material):
	material_override = mat
