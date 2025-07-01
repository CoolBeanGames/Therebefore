extends Node
class_name Audio

enum audio_bus{master,sfx,music,vocal,phone,ui, reverbSFX, reverbVocal}

func play(clip : AudioStream,randomize_pitch : bool = false,bus : audio_bus = audio_bus.master, use_position : bool = false, position : Vector3 = Vector3(0,0,0)):
	pass
