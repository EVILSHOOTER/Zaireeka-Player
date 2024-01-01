extends CharacterBody3D


const SPEED := 8.0
const JUMP_VELOCITY := 13.0
const SENSITIVITY := 0.005
const LOOK_DOWN_LIMIT := deg_to_rad(-90) # was -30
const LOOK_UP_LIMIT := deg_to_rad(110) # was 60
const LERP_SPEED := 0.1
const ACCELERATION := 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var body := self # necessary?

func _ready():
	neck.set_as_top_level(true) # do not follow parent's position/rotation

func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#elif event.is_action_pressed("ui_cancel"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, LOOK_DOWN_LIMIT, LOOK_UP_LIMIT)

func _physics_process(delta: float) -> void:
	# FACE CHARACER: face the character where the neck is pointing eventually
	# the neck is nice cuz it acts like orientation more than cframe. could save a base cframe though
	# use the neck for the character rotation though?
	rotation.y = (lerp_angle(rotation.y, neck.rotation.y, LERP_SPEED)) # nicer for angles.
	
	var newVelocity = 0
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED: # lazy but whatever
		input_dir = Vector2(0,0)

	# WALKING: using body's facing direction, move in relation to that
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	newVelocity = lerp(velocity, direction * SPEED, ACCELERATION * delta)
	
	if not is_on_floor(): # Add the gravity.
		newVelocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): # Handle Jump.
		newVelocity.y = JUMP_VELOCITY
	
	velocity = newVelocity
	move_and_slide()
	

func _process(delta):
	# since neck is now at top level, manually set the pos of it
	neck.position = position + get_global_transform().basis.y*0.5 # kinda like having an up vector

# can you make the body rotate too, not move in the direction of where the neck is facing?
