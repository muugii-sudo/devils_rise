extends CharacterBody3D

var speed = 4.0
var gravity = 9.814
var mouse_sensitivity = 0.002
var yaw = 0.0
var pitch = 0.0

var is_ragdoll = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.2, 1.2)
		rotation.y = yaw
		$Camera3D.rotation.x = pitch
	
	if event.is_action_pressed("key_r"):
		toggle_ragdoll()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized().rotated(Vector3.UP, yaw)
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	
	move_and_slide()

func toggle_ragdoll():
	is_ragdoll = !is_ragdoll
	if is_ragdoll:
		velocity = Vector3.ZERO
		rotation_degrees.x = -90
	else:
		rotation_degrees = Vector3.ZERO
