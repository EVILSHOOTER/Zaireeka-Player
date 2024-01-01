extends Node3D

@onready var camera :=  $"../Neck/Camera3D" #$"../Head/Camera"
@onready var speakerSystem := get_tree().get_current_scene().get_node("SpeakerSystem")

const rotation_speed := 200
const position_offset := Vector3(0,0.5,0)

var mouseDown := false
var heldSpeaker : StaticBody3D
var heldSet : Node3D # this is vastly different enough that i dont wanna merge code with speakers.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# functions used solely for single moments in a way bigger function
func setCollision(object, value): # dirty but works.
	object.collision_layer = 0x001 if value else 0x000
	#object.input_ray_pickable = value

func setSeveralCollisions(daNode, value):
	var waiting = daNode.get_children()
	while not waiting.is_empty():
		var node = waiting.pop_back() as Node
		waiting.append_array(node.get_children())
		if node is StaticBody3D or node is Area3D:
			setCollision(node, value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		return
		
	var current_mouseDown = Input.is_action_pressed("left_click")
	var justnow_mouseDown = Input.is_action_just_pressed("left_click")
	var current_rotation = rotation_speed*delta if Input.is_action_pressed("rotate") else 0
	
	# drag function
	const rayDistance = 1000
	var spaceState = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousePos)
	var end = origin + camera.project_ray_normal(mousePos) * rayDistance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true # switch off when not dragging speakers.
	var result = spaceState.intersect_ray(query)
	
	if result:
		var hitObject : Node3D = result["collider"]
		var hitPos : Vector3 = result["position"]
		
		if justnow_mouseDown: # start click: hold a speaker (if pointed at one).
			if hitObject.get_meta("object_type") == "Speaker" and not heldSpeaker:
				heldSpeaker = hitObject
				workaround_reparent(heldSpeaker, speakerSystem) # heldSpeaker.reparent(speakerSystem)
				setCollision(heldSpeaker, false)
			elif hitObject.get_meta("object_type") == "JointArea" and not heldSet:
				heldSet = hitObject.get_parent().get_parent() # ugly af wtf. only in roblox
				setSeveralCollisions(heldSet, false)
		
		if heldSet:
			if current_mouseDown:
				heldSet.position = hitPos - position_offset
				heldSet.rotation_degrees.y += current_rotation
			else:
				setSeveralCollisions(heldSet, true)
				heldSet = null
		elif heldSpeaker:
			if current_mouseDown:
				heldSpeaker.position = hitPos - position_offset
				heldSpeaker.rotation_degrees.y += current_rotation
				if hitObject.name == "jointArea": # click into place preview+let-go.
					var speakerSpot = hitObject.get_parent().get_node("speakerSpot") 
					if speakerSpot and speakerSpot.get_child_count() == 0:
						workaround_reparent(heldSpeaker, speakerSpot) #heldSpeaker.reparent(speakerSpot)
						
					if heldSpeaker.get_parent().name == "speakerSpot": # if docked
						heldSpeaker.position = Vector3(0,0,0)
						heldSpeaker.rotation = Vector3(0,0,0)
				else: # if dragging + pointed away from dock, un-parent
					if heldSpeaker.get_parent() != speakerSystem:
						workaround_reparent(heldSpeaker, speakerSystem) # heldSpeaker.reparent(speakerSystem)
						
			else: # mouse release: plant the speaker
				setCollision(heldSpeaker, true)
				heldSpeaker = null

# upon reparent(), godot unpauses audio. no goddamn clue why. took me a bit to figure this one out
func workaround_reparent(speaker, newParent):
	var player : AudioStreamPlayer3D = speaker.get_node("music")
	#var playing := player.playing
	var paused := player.stream_paused
	#var time := player.get_playback_position()
	speaker.reparent(newParent)
	#player.seek(time)
	#player.playing = playing
	player.stream_paused = paused
	#speakerSystem.masterControl("seek", speakerSystem.mainTrack.get_playback_position()) # test.
	

func _unhandled_input(event):
	#print(event)
	pass

