extends Node
class_name subtitled_audio_player

@export var is_playing : bool = false
@export var current_group : subtitled_audio_group
@export var current_audio : subtitled_audio
@export var current_player : AudioPlayer
@export var subtitles : Label
@export var index : int = 0

func start_playing(group : subtitled_audio_group):
	if !is_playing and group.lines.size() > 0:
		if subtitles == null:
			subtitles = GameData.references["subtitles"] as Label
		is_playing = true
		current_group = group
		index=0
		current_audio = current_group.lines[index]
		#setup the player
		current_player = AudioManager.playSound(current_audio.Audio)
		subtitles.text = current_audio.Text
		current_player.stream_finished.connect(audio_finished.bind())

func start_playing_positional(group : subtitled_audio_group , position : Vector3):
	if !is_playing and group.lines.size() > 0:
		if subtitles == null:
			subtitles = GameData.references["subtitles"] as Label
		is_playing = true
		current_group = group
		index=0
		current_audio = current_group.lines[index]
		#setup the player
		current_player = AudioManager.playPositionalSound(current_audio.Audio,position)
		subtitles.text = current_audio.Text
		current_player.stream_finished.connect(audio_finished.bind())


func audio_finished():
	#check if the lines are finished
	index += 1
	if index >= current_group.lines.size():
		finished_player()
		return
	#otherwise load the next line
	current_audio = current_group.lines[index]
	#setup the player
	current_player = AudioManager.playSound(current_audio.Audio)
	subtitles.text = current_audio.Text
	current_player.stream_finished.connect(audio_finished.bind())

func audio_finished_positional():
		#check if the lines are finished
	index += 1
	if index >= current_group.lines.size():
		finished_player()
		return
	#otherwise load the next line
	current_audio = current_group.lines[index]
	#setup the player
	current_player = AudioManager.playSound(current_audio.Audio)
	subtitles.text = current_audio.Text
	current_player.stream_finished.connect(audio_finished.bind())

func finished_player():
	subtitles.text = ""
	current_group=null
	current_audio=null
	index=0
	is_playing=false
	current_player=null
	pass
