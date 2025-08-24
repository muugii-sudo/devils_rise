extends CharacterBody3D

@export var speed = 4.0
@export var mouse_sensitivity = 0.002

var yaw = 0.0
var pitch = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.2, 1.2) # prevent flipping
		rotation.y = yaw
		$Camera3D.rotation.x = pitch

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized().rotated(Vector3.UP, yaw)
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	move_and_slide()

var is_grabbing = false
@export var grab_distance = 2.5

func _process(delta):
	var ray = $Camera3D/RayCast3D
	if ray.is_colliding():
		var collider = ray.get_collider()
		if Input.is_action_pressed("grab") and not is_grabbing:
			is_grabbing = true
			velocity = Vector3.ZERO
		elif Input.is_action_just_released("grab"):
			is_grabbing = false

@export var max_stamina = 100
var stamina = max_stamina

func _physics_process_stamina(delta):
	if is_grabbing:
		stamina -= delta * 15 # drain while grabbing
		if stamina <= 0:
			is_grabbing = false
		else:
			stamina = min(max_stamina, stamina + delta * 5) # recover
