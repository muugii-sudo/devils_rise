extends RigidBody3D

@export var speed := 8.0
@export var mouse_sensitivity := 0.002

var pitch := 0.0
var is_ragdoll := false
var yaw_input := 0.0
var is_grappling = false
var grapple_point: Vector3

@onready var arm_ray = $RayCast3D 
@onready var arm = $RightArm2
@onready var cam := $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lock_upright()

func _input(event):
	if event is InputEventMouseMotion and not is_ragdoll:
		yaw_input = -event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.3, 1.3)
		cam.rotation.x = pitch
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			arm._extend()

	if event.is_action_pressed("key_r"):
		toggle_ragdoll()

func _integrate_forces(state):
	if is_ragdoll:
		return

	var ang_vel = angular_velocity
	ang_vel.y = yaw_input * 60
	angular_velocity = ang_vel
	yaw_input = 0

	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()

	var basis_yaw = Transform3D(Basis(Vector3.UP, rotation.y), Vector3.ZERO)
	var move_dir = (basis_yaw * input_dir).normalized()
	var vel = linear_velocity
	vel.x = move_dir.x * speed
	vel.z = move_dir.z * speed
	linear_velocity = vel

func toggle_ragdoll():
	is_ragdoll = !is_ragdoll
	if is_ragdoll:
		axis_lock_angular_x = false
		axis_lock_angular_z = false
	else:
		lock_upright()

func lock_upright():
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	rotation_degrees.x = 0
	rotation_degrees.z = 0
