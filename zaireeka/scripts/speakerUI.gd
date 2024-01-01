extends CanvasLayer

# this should be as simple as editing the values in the speakers node found in workspace
# process just gon display he values seen in the speakers node rlly. remember 2 allow for control.
# this'll get more complicated the more that's added but whatever rlly

@export var infoButton : Button

@export var discUI : HBoxContainer
@export var speakersUIContainer : VBoxContainer
@export var speakerSystem : Node
@export var mainTrack : AudioStreamPlayer3D

@export var button_backward : Button
@export var button_backward2 : Button
@export var button_play : Button
@export var button_forward : Button
@export var button_forward2 : Button
@export var button_shuffle : Button
@export var button_repeat : Button

@export var timeline : HSlider
@export var masterVolume : HSlider 
@export var currentTime : Label
@export var endTime : Label

@export var songDetails : RichTextLabel

var followSeek = true # prevent updating timeline while y000 y000z it
var speakersUIList = {}
var mouseDrag := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED): 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			focusReleaser()

func _ready():
	infoButton.pressed.connect(func(): OS.shell_open("https://github.com/EVILSHOOTER/Zaireeka-Player") )
	
	button_play.pressed.connect(buttonControl.bind("play/pause"))
	button_forward.button_down.connect(buttonControl.bind("fast forward ON"))
	button_forward.button_up.connect(buttonControl.bind("fast forward OFF"))
	button_backward.button_down.connect(buttonControl.bind("rewind ON"))
	button_backward.button_up.connect(buttonControl.bind("rewind OFF"))
	button_forward2.button_down.connect(buttonControl.bind("next song"))
	button_backward2.button_down.connect(buttonControl.bind("previous song"))
	button_shuffle.button_down.connect(buttonControl.bind("shuffle"))
	button_repeat.button_down.connect(buttonControl.bind("repeat"))
	
	timeline.drag_started.connect(timelineControlStart.bind())
	timeline.value_changed.connect(timelineControlMove.bind()) # affected by updateUI constantly doing it?
	timeline.drag_ended.connect(timelineControlEnd.bind()) # uses param itself so gotta not have ur own -_-
	
	masterVolume.value_changed.connect(volumeControl.bind()) 
	
	# save the DISC controls UI into a variable and move/remove the old one.
	var old_discUI = discUI # figure out a better way, like just moving the node to nil
	discUI = old_discUI.duplicate()
	old_discUI.queue_free()
	
	createSpeakerControls()

func _process(delta):
	updateUI()
	
############################
func buttonControl(action):
	speakerSystem.masterControl(action)
func timelineControlStart():
	followSeek = false
func timelineControlMove(value_changed):
	pass
func timelineControlEnd(value_changed):
	followSeek = true
	speakerSystem.masterControl("seek", (timeline.value/100) * mainTrack.stream.get_length() )
func volumeControl(value_changed):
	speakerSystem.masterControl("volume", masterVolume.value)
func individualSpeakerVolumeControl():
	pass

# run on childAdded/Removed or similar?
func createSpeakerControls():
	# remove the last set of speaker controls
	for speakerUI in speakersUIContainer.get_children():
		if speakerUI.name != "titles":
			speakerUI.queue_free()
	
	# incredibly ugly as this just goes by pure assumption but, speaker-count = cd1's tracks / 2. .___.
	while speakerSystem.allSettings == {}:
		await get_tree().create_timer(0.1).timeout # o ma lawrd that is disgusting
	for i in speakerSystem.allSettings:
		var newUI := discUI.duplicate()
		newUI.get_node("name").text = "#" + str(i)
		var vol1 = newUI.get_node("volume").get_node("HSlider")
		var vol2 = newUI.get_node("volume2").get_node("HSlider")
		vol1.value_changed.connect(speakerSystem.editSpeakerVolume.bind(i,7)) # e.g. speakerSystem[i][7] 
		vol2.value_changed.connect(speakerSystem.editSpeakerVolume.bind(i,8))
		# add both UI sliders to the list of elements to release focus from as well.
		speakersUIContainer.add_child(newUI)
		
	# update the details of the UI using speakerSettings. make a separate function for this. reuse in _process
	updateUI()

func seconds_to_time(value):
	var time = str( "%02d" % int(value / 60)) + ":" + str("%02d" % (int(value) % 60))
	return time

func updateUI(): # read allSettings and update the UI.
	# uhhh the UI elements have to be read alongside the speakerSettings. kinda weird. better methods?
		# save the UI within each setting?
	if followSeek:
		timeline.value = (mainTrack.get_playback_position()/mainTrack.stream.get_length())*100
	currentTime.text = seconds_to_time(timeline.value/100 * mainTrack.stream.get_length())
	endTime.text = seconds_to_time(mainTrack.stream.get_length())
	
	button_shuffle.get_node("tick").visible = true if speakerSystem.shuffle else false
	button_repeat.get_node("tick").visible = true if speakerSystem.repeat else false
	
	button_play.get_node("contents").text = "[center][img=30]" + ("pictures/UIbuttons/forward.png" if speakerSystem.paused else "pictures/UIbuttons/pause.png") + "[/img][/center]"
	
	songDetails.text = "[center]" + speakerSystem.currentSongMetadata["name"] + "
[b]"+speakerSystem.currentSongMetadata["artist"]+"[/b] - [i]"+speakerSystem.currentSongMetadata["album"]+"[/i][/center]"

func focusReleaser():
	var things_to_focus_from = [button_backward, button_backward2, button_play, 
	button_forward, button_forward2, button_shuffle, button_repeat, timeline, masterVolume]
	for thing in things_to_focus_from:
		thing.release_focus()

