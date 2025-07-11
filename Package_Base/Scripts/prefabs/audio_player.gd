extends AudioStreamPlayer3D
class_name audio_player

@export var player_3D : AudioStreamPlayer3D
@export var player_global : AudioStreamPlayer
@export var player_id : int = 0

signal audio_finished(player : audio_player)

func start(clip : AudioStream,randomize_pitch : bool = false,_bus : Audio.audio_bus = Audio.audio_bus.master, use_position : bool = false, _position : Vector3 = Vector3(0,0,0)):
	if use_position:
		_setup_3D(clip,randomize_pitch, _bus , _position)
	else:
		_setup_global(clip,randomize_pitch, _bus )

func _setup_3D(clip : AudioStream,randomize_pitch : bool = false,_bus : Audio.audio_bus = Audio.audio_bus.master, _position : Vector3 = Vector3(0,0,0)):
	player_3D.stream = clip
	if randomize_pitch:
		var r = RandomNumberGenerator.new()
		r.randomize()
		var v = r.randf_range(0.8,1.2)
		player_3D.pitch_scale = v
	else:
		player_3D.pitch_scale = 1
	player_3D.bus = AudioServer.get_bus_name(_bus)
	
	player_3D.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	player_3D.global_transform.origin =  _position
	player_3D.finished.connect(finished_3d)
	player_3D.play()
	

func _setup_global(clip : AudioStream,randomize_pitch : bool = false,_bus : Audio.audio_bus = Audio.audio_bus.master):
	player_global.stream = clip
	if randomize_pitch:
		var r = RandomNumberGenerator.new()
		r.randomize()
		var v = r.randf_range(0.8,1.2)
		player_global.pitch_scale = v
	else:
		player_global.pitch_scale = 1
	player_global.bus = AudioServer.get_bus_name(_bus)
	player_global.finished.connect(finished_global)
	player_global.play()

func _stop():
	player_global.stop()
	player_3D.stop()

func finished_3d():
	audio_finished.emit(self)
	player_3D.finished.disconnect(finished_3d)

func finished_global():
	audio_finished.emit(self)
	player_global.finished.disconnect(finished_global)
