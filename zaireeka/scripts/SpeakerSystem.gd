extends Node3D

signal PLAYBITCH
signal PAUSEMOTHERFUCKERGODDAMNIT
signal STOPTHATSHITHOLYFUCKMYDAYSBRO

const path := "res://"
const speakersetPath = path + "objects/SpeakerSet.tscn"
const audioPath := path + "audio/zaireeka/" 

@export var allSettings : Dictionary
@export var playing : bool = false
@export var paused : bool = true
@export var rewinding : bool
@export var speeding : bool
@export var currentTrack : int = 1
@export var shuffle : bool
@export var repeat : bool
@export var volume : int = 100
@export var allTracks : Dictionary
@export var mainTrack : AudioStreamPlayer3D
@export var currentSongMetadata : Dictionary = {"artist" : "", "album" : "", "name" : ""}

enum SETTING {NAME, LEFT_SONG, RIGHT_SONG, EQ, SPEAKER_SET, LEFT_SPEAKER, RIGHT_SPEAKER, LEFT_VOLUME, RIGHT_VOLUME}
var default_speakerSetting = {
	SETTING.NAME: "#1", 
	SETTING.LEFT_SONG: "",
	SETTING.RIGHT_SONG: "",
	SETTING.EQ: null,
	SETTING.SPEAKER_SET: null, 
	SETTING.LEFT_SPEAKER: null,
	SETTING.RIGHT_SPEAKER: null,
	SETTING.LEFT_VOLUME: 100, 
	SETTING.RIGHT_VOLUME: 100, 
	}
enum TSETTING {L1, L2, L3, L4, R1, R2, R3, R4} # save the actual audio streams.


func _ready():
	var numberOfSpeakersRequired = loadSongs()
	createSpeakerSets(numberOfSpeakersRequired)
	changeTrack(currentTrack)
	mainTrack.finished.connect(masterControl.bind("next song"))

func _process(delta):
	pass

# iterate through files in a directory. https://docs.godotengine.org/en/stable/classes/class_diraccess.html
func dir_contents(path) -> Array:
	var dir = DirAccess.open(path)
	var fileArray = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass #print("Found directory: " + file_name)
			else:
				pass #print("Found file: " + file_name)
				
				# was "if NOT". you need the .import!
				# when exported, only the .import paths remain. so look for those instead. :/
				# when load()-ing, remove the ".import" part. ".wav" is able to be referenced. what???
				if file_name.contains(".import"): 
					fileArray.append(file_name)
			file_name = dir.get_next()
		#print(dir.get_files())
	else:
		print("An error occurred when trying to access the path.")
	fileArray.sort()
	return fileArray


func loadSongs():
	allTracks = {} # 8 entries. 4 2-ples in each  (2 speaker songs)
	
	# iterate through the main audio folder. find all folders in it. they are expected to be numbered.
	var tracksPath = audioPath
	var totalTracks := DirAccess.open(tracksPath).get_directories().size()
	var totalDiscs := dir_contents(tracksPath+"1/").size()/2 # ASSUMPTION: every folder has the same no of tracks!
	
	for trackNo in range(1, totalTracks+1):
		#var newSetting = defaultSetting.duplicate()
		var track := []
		var p = tracksPath+str(trackNo)+"/"
		var currentTrack = dir_contents(p)
		# change this whenever u get stereo panning done right
		for discNo in range(1, currentTrack.size()/2 + 1):
			track.append([ load( (p+currentTrack[(discNo-1)*2]).replace(".import","") ) , load( (p+currentTrack[(discNo-1)*2 +1]).replace(".import","") ) ])
			
			# imported godot resources must be handled differently:
			# https://forum.godotengine.org/t/how-to-get-load-imported-resources-that-work-in-exported-projects/2408/2
			
		allTracks[trackNo] = track
	
	return totalDiscs

func createSpeakerSets(inputtedSets):
	allSettings = {} # do a clear up procedure? for new songs IF I ever do that
	
	for i in range(1, inputtedSets+1):
		#var inputtedSetting = inputtedSets[i]
		
		var speakerSet = load(speakersetPath).instantiate() 
		var speakerL = speakerSet.get_node("leftJoint/speakerSpot/Speaker")
		var speakerR = speakerSet.get_node("rightJoint/speakerSpot/Speaker")
		
		# save the speaker in an array.
		var newSetting = default_speakerSetting.duplicate()
		newSetting[SETTING.NAME] 			= str(i) # ("#" + str(i)) 
		newSetting[SETTING.LEFT_SONG] 		= null #inputtedSetting.get(SETTING.LEFT_SONG)
		newSetting[SETTING.RIGHT_SONG] 		= null #inputtedSetting.get(SETTING.RIGHT_SONG)
		newSetting[SETTING.EQ] 				= null # for a while anyway
		newSetting[SETTING.SPEAKER_SET] 	= speakerSet
		newSetting[SETTING.LEFT_SPEAKER] 	= speakerL
		newSetting[SETTING.RIGHT_SPEAKER] 	= speakerR
		newSetting[SETTING.LEFT_VOLUME] 	= 100 #inputtedSetting.get(SETTING.LEFT_VOLUME) 
		newSetting[SETTING.RIGHT_VOLUME] 	= 100 #inputtedSetting.get(SETTING.RIGHT_VOLUME) 
		allSettings[i] = newSetting
		
		# setting the position. just make it a buncha defaults.
		var d = 8 # default
		var places = {
			1: {"pos":Vector3(-d,0,-d), "rot":Vector3(0, -45, 0)},
			2: {"pos":Vector3(d,0,-d), "rot":Vector3(0, -135, 0)},
			3: {"pos":Vector3(d,0,d), "rot":Vector3(0, 135, 0)},
			4: {"pos":Vector3(-d,0,d), "rot":Vector3(0, 45, 0)},
		}
		speakerSet.position = places[i]["pos"]
		speakerSet.rotation_degrees = places[i]["rot"]
		
		# num84h D@ 5p33k4h DOTN SPEAK IK JUS w@t y000 54yy111111n
		speakerL.get_node("numberFront").text = newSetting[SETTING.NAME]
		speakerL.get_node("numberBack").text = newSetting[SETTING.NAME]
		speakerR.get_node("numberFront").text = newSetting[SETTING.NAME]
		speakerR.get_node("numberBack").text = newSetting[SETTING.NAME]
		
		# make some changes to the speakers.
		var audioPlayerL = AudioStreamPlayer3D.new()
		var audioPlayerR = AudioStreamPlayer3D.new()
		audioPlayerL.name="music"
		audioPlayerR.name="music"
		speakerL.add_child(audioPlayerL)
		speakerR.add_child(audioPlayerR)
		
		# set the settings of the speaker, who cares
		audioPlayerL.volume_db = newSetting[SETTING.LEFT_VOLUME] - 100
		audioPlayerR.volume_db = newSetting[SETTING.RIGHT_VOLUME] - 100
		# 8000 is the limit rn. wtf. should be 20500 but your ears just get raped
		audioPlayerL.attenuation_filter_cutoff_hz = 7990
		audioPlayerR.attenuation_filter_cutoff_hz = 7990
		
		add_child(speakerSet)

func changeTrack(trackNumber):
	var trackDetails = allTracks[trackNumber] # e.g. track 3 - [1L,1R] ... [4L,4R]
	
	# jweignwri9gn r just use the first track, scr00 3t
	mainTrack.stream = trackDetails[0][0]
	
	# have parameter? playTrack. useful for seemlessly playing songs.
	playing = false # this is where it gets a lil funny. 
	paused = true
	
	# get allSettings and update all the speakers in line with the trakcs you've loaded.
	for i in allSettings: # expecting i is the same for trackdetails.
		allSettings[i][SETTING.LEFT_SONG] = trackDetails[i-1][0]
		allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").stream = trackDetails[i-1][0]
		allSettings[i][SETTING.RIGHT_SONG] = trackDetails[i-1][1]
		allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").stream = trackDetails[i-1][1]
	
	# set the metadata. read the file, but cba figuring that out rn
	var file = audioPath + "metadata.json"
	var jsonText = FileAccess.get_file_as_string(file)
	var jsonDict = JSON.parse_string(jsonText)
	if jsonDict:
		var j = jsonDict[str(trackNumber)]
		currentSongMetadata = {"artist" : j["artist"], "album" : j["album"], "name" : j["name"]}

func masterControl(action, param1 = null):
	# use a maintrack. this is what all the others follow
	if action == "play/pause":
		if not playing:
			mainTrack.play()
			playing = true
			
			for i in allSettings:
				allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").playing = mainTrack.playing
				allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").playing = mainTrack.playing
			
		paused = not paused
		mainTrack.stream_paused = paused
	elif action == "fast forward ON":
		speeding = true
		mainTrack.pitch_scale = 3
	elif action == "fast forward OFF":
		speeding = false
		mainTrack.pitch_scale = 1
	elif action == "rewind ON":
		rewinding = true
		var rewindTime = 3
		var waitTime = 0.5
		while rewinding:
			var seek = clamp(mainTrack.get_playback_position() - rewindTime, 0, 9999)
			masterControl("seek", seek)
			await get_tree().create_timer(waitTime).timeout
	elif action == "rewind OFF":
		rewinding = false
	elif action == "next song":
		if not repeat:
			currentTrack = clamp(currentTrack+1, 1, allTracks.size())
			if shuffle:
				currentTrack = randi_range(1, allTracks.size())
		changeTrack(currentTrack) # pick random if shuffle on
		masterControl("play/pause")
	elif action == "previous song":
		currentTrack = clamp(currentTrack-1, 1, allTracks.size())
		changeTrack(currentTrack)
		masterControl("play/pause")
	elif action == "seek": # param1 is seek.
		mainTrack.seek(param1)
		for i in allSettings: # kinda fugly but whatever.
			allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").seek(param1)
			allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").seek(param1)
	elif action == "shuffle":
		shuffle = not shuffle
	elif action == "repeat":
		repeat = not repeat
	elif action == "volume":
		volume = param1
		mainTrack.volume_db = volume - 100
	
	# for the rest of the properties that can seemlessly be edited during play, leave 'em here
	for i in allSettings:
		allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").stream_paused = mainTrack.stream_paused
		allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").stream_paused = mainTrack.stream_paused
		
		allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").pitch_scale = mainTrack.pitch_scale
		allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").pitch_scale = mainTrack.pitch_scale
		
		# volume control: individual volume should be a % of the master. master is its 100%
		allSettings[i][SETTING.LEFT_SPEAKER].get_node("music").volume_db = mainTrack.volume_db - ( (100.0-allSettings[i][SETTING.LEFT_VOLUME]) *(volume/100.0) )
		allSettings[i][SETTING.RIGHT_SPEAKER].get_node("music").volume_db = mainTrack.volume_db - ( (100.0-allSettings[i][SETTING.RIGHT_VOLUME]) *(volume/100.0) )

func editSpeakerVolume(value, speakerSet, setting):
	allSettings[speakerSet][setting] = value # 5/6 = left/right speaker. 7/8 = left/right volume values.
	masterControl("") # idegaf atp bruh hahaha

# an idea I had in the beginning. might be useful, but atm is looking to be impracticle
func editSpeakerSetting(blegh, speaker, setting, value):
	pass

func editAllSpeakerSettings(key, value):
	# run editSpeakerSetting for all speakers in the dictionary.
	pass

# connect dem events, 81TC|-|
#Signal.connect(Callable masterControl)

# from another game, two ways ik of doing connect
#$ActivationArea.body_entered.connect(checkpointivate) 
#connect("body_entered", Callable($ActivationArea, "checkpointivate")) # dunno y this 1 ain't working

#connect("masterControl", )
