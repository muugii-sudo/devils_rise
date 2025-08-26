extends RigidBody3D

@export var speed := 8.0
@export var mouse_sensitivity := 0.002
@export var drag_speed := 12.0

var pitch := 0.0
var yaw_input := 0.0
var is_ragdoll := false
var is_grappling := false
var grapple_point: Vector3
var jump_height = 8.0
var upwards_velocity = 3

@onready var cam := $Camera3D
@onready var right_arm := $RightArm
@onready var left_arm := $LeftArm
@onready var player := $Player


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lock_upright()
	
	var direction = (grapple_point - position).normalized()
	var pull_strength = clamp((grapple_point - position).length(), 0, $RightArm.max_distance)
	linear_velocity = direction * pull_strength

func _input(event):
	if event is InputEventMouseMotion and not is_ragdoll:
		yaw_input = -event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.3, 1.3)
		cam.rotation.x = pitch
		
	if event.is_action_pressed("space"):
		var input_dir = Input.get_action_strength("space")
		var move_dir = (input_dir)
		var vel = linear_velocity
		print("space pressed~!")
		vel.y = move_dir * jump_height 
	
	if event.is_action_pressed("key_r"):
		toggle_ragdoll()
	
	if event.is_action_pressed("rmb"):
		right_arm.extend()
	
	if event.is_action_released("rmb"):
		is_grappling = false
		
	if event.is_action_pressed("lmb"):
		left_arm.extend()
		
	if event.is_action_released("lmb"):
		is_grappling = false

func _integrate_forces(_state):
	if is_ragdoll:
		return
		
	var ang_vel = angular_velocity
	ang_vel.y = yaw_input * 60
	angular_velocity = ang_vel
	yaw_input = 0
	
	# Basic movement
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir.y = Input.get_action_strength("space")
	input_dir = input_dir.normalized()
	var basis_yaw = Transform3D(Basis(Vector3.UP, rotation.y), Vector3.ZERO)
	var move_dir = (basis_yaw * input_dir).normalized()
	var vel = linear_velocity
	vel.x = move_dir.x * speed
	vel.z = move_dir.z * speed
	
	if is_grappling and grapple_point:
		var dir_to_grapple = (grapple_point - global_transform.origin)
		var dist = dir_to_grapple.length()
		gravity_scale = 0
		if dist < 0.1:
			is_grappling = false
		else:
			vel += dir_to_grapple.normalized() * drag_speed
	linear_velocity = vel
	
	gravity_scale = 2
	
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
