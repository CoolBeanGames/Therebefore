extends Node
class_name _audio

@export var player_3D : AudioStreamPlayer3D
@export var player_global : AudioStreamPlayer

enum audio_bus{master,sfx,music,vocal,phone,ui,reverbSFX,reverbVocal}

func play(clip : AudioStream,randomize_pitch : bool = false,bus : audio_bus = audio_bus.master, use_position : bool = false, position : Vector3 = Vector3(0,0,0)):
	pass
