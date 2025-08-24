extends CharacterBody3D

var speed = 4.0
var mouse_sensitivity = 0.002
var yaw = 0.0
var pitch = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.2, 1.2)
		rotation.y = yaw
		$Camera3D.rotation.x = pitch

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized().rotated(Vector3.UP, yaw)
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	move_and_slide()
