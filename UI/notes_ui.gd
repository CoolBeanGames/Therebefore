extends PanelContainer
class_name notes

@export var visibility_parent : Control

@export var image : TextureRect
@export var text_contents : RichTextLabel
@export var page_couinter : Label
@export var button_prompts : Label
@export var note_page : int
@export var note : note_res
@export var is_active : bool = false
@export var text_active : bool = false

#audio players
@export var note_open_sound : AudioStream
@export var note_close_sound : AudioStream
@export var note_right_sound : AudioStream
@export var note_left_sound : AudioStream
@export var error_sound : AudioStream

#signal
signal note_opened (note : note_res)
signal note_closed (note : note_res)

func start_showing_note(_note : note_res):
	##todo: lock input
	note_page = 0
	note = _note
	is_active=true
	if note == null  or  note.pages.size() == 0:
		printerr("tried to show a note, but the note has no pages")
		note = null
		is_active=false
		return
	check_note_page_bounds()
	update_page_string()
	update_note_text()
	note_opened.emit(_note)
	Audio.play(note_open_sound,false,Audio.audio_bus.sfx)
	visibility_parent.visible=true
	GameData.lock_input(self)

func _process(_delta: float) -> void:
	if is_active:
		if Input.is_action_just_released("left"):
			page_left()
		if Input.is_action_just_released("right"):
			page_right()
		if Input.is_action_just_released("exit"):
			stop_showing_note()

#stops showing the note if one is showing and clears all data
func stop_showing_note():
	##todo: unlock input
	GameData.release_input_lock(self)
	if note != null:
		note_closed.emit(note)
		Audio.play(note_close_sound,false,Audio.audio_bus.sfx)
		GameData.set_flags(note.flags)
	note = null
	image = null
	page_couinter.text = "-- / --"
	text_contents.text = "[no text was set]"
	note_page = 0
	is_active=false
	visibility_parent.visible = false


#update the current page indicator
func update_page_string():
	#early exit checks
	if !is_active:
		print("tried to update note page, but note is not active")
		return
	if note == null:
		#no note is set so return
		stop_showing_note()
		print("tried to update page, but no note was set")
		return
	page_couinter.text = str(note_page + 1) + " / " + str(note.pages.size())

##checks to make sure the note is within bounds
func check_note_page_bounds():
	#early exit checks
	if !is_active:
		print("tried to clamp note page, but note is not active")
		return
	if note == null:
		#no note is set so return
		stop_showing_note()
		print("tried to clamp note page, but no note was set")
		return
	note_page = clamp(note_page,0,note.pages.size()-1)

#sets the main text content for the note
func update_note_text():
	if !is_active:
		print("tried to update note text, but note is not active")
		return
	if note == null:
		#no note is set so return
		stop_showing_note()
		print("tried to update note text, but no note was set")
		return
	check_note_page_bounds()
	text_contents.text = note.pages[note_page]

#navigates to the next page
func page_right():
	#early exit checks
	if !is_active:
		print("tried go up one page, but note is not active")
		return
	if note == null:
		#no note is set so return
		stop_showing_note()
		print("tried to go up one page, but no note was set")
		return
	note_page += 1
	if note_page > note.pages.size()-1:
		#todo: play error sound
		Audio.play(error_sound,false,Audio.audio_bus.sfx)
	else:
		Audio.play(note_right_sound,false,Audio.audio_bus.sfx)
	check_note_page_bounds()
	update_page_string()
	update_note_text()

#navigates to the last page
func page_left():
	if !is_active:
		print("tried go down one page, but note is not active")
		return
	if note == null:
		#no note is set so return
		stop_showing_note()
		print("tried to go down one page, but no note was set")
		return
	note_page -= 1
	if note_page < 0:
		#todo play error sound
		Audio.play(error_sound,false,Audio.audio_bus.sfx)
	else:
		Audio.play(note_left_sound,false,Audio.audio_bus.sfx)
	check_note_page_bounds()
	update_page_string()
	update_note_text()
