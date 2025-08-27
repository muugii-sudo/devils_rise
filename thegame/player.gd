extends RigidBody3D

@export var speed := 8.0
@export var sprint_speed := 14.0 # Speed while sprinting
@export var mouse_sensitivity := 0.002
@export var drag_speed := 12.0
@export var jump_height := 8.0
@export var wall_jump_strength := 10.0
@export var wall_check_distance := 1.0
@export var max_slope_angle := 40.0 # Maximum slope angle in degrees


var pitch := 0.0
var yaw_input := 0.0
var is_ragdoll := false
var is_grappling := false
var grapple_point: Vector3
var health = 1
var current_speed := speed # Will smoothly transition between walk & sprint

@onready var cam := $Camera3D
@onready var right_arm := $RightArm
@onready var left_arm := $LeftArm
@onready var ground_check := $GroundRayCast
@onready var wall_check := $WallRayCast
@onready var death_screen: ColorRect = $"../CanvasLayer/ColorRect"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lock_upright()

func _input(event):
	if event is InputEventMouseMotion and not is_ragdoll:
		yaw_input = -event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.3, 1.3)
		cam.rotation.x = pitch
	
	if event.is_action_pressed("space"):
		handle_jump()
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

func handle_jump():
	if ground_check.is_colliding():
		linear_velocity.y = jump_height
		return
	
	if wall_check.is_colliding():
		var wall_normal = wall_check.get_collision_normal()
		linear_velocity = wall_normal * wall_jump_strength
		linear_velocity.y = jump_height

func _integrate_forces(_state):
	if is_ragdoll:
		return
	
	var is_on_ground = ground_check.is_colliding()
	var was_on_ground = false
	var safe_speed = 30
	
	if !was_on_ground and is_on_ground:
		var fall_speed = abs(linear_velocity.y)
		if fall_speed > safe_speed:
			var speed_dif = fall_speed - safe_speed
			var damage = speed_dif
			apply_fall_damage(damage)
	was_on_ground = is_on_ground
	
	var ang_vel = angular_velocity
	ang_vel.y = yaw_input * 60
	angular_velocity = ang_vel
	yaw_input = 0
	
	# Sprint Handling 
	if Input.is_action_pressed("shift"):
		current_speed = sprint_speed
	else:
		current_speed = speed
	
	# Check ground slope
	var on_ground = ground_check.is_colliding()
	var can_move = true
	
	if on_ground:
		var ground_normal = ground_check.get_collision_normal()
		var slope_angle = rad_to_deg(acos(ground_normal.dot(Vector3.UP)))

		# If slope is too steep, block movement
		if slope_angle > max_slope_angle:
			can_move = false
		
	# Only allow movement if slope is okay
	if can_move:
		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
		input_dir = input_dir.normalized()
		
		var basis_yaw = Transform3D(Basis(Vector3.UP, rotation.y), Vector3.ZERO)
		var move_dir = (basis_yaw * input_dir).normalized()
		
		var vel = linear_velocity
		vel.x = move_dir.x * current_speed
		vel.z = move_dir.z * current_speed
		linear_velocity = vel
	else:
		# Stop horizontal velocity on steep slopes
		linear_velocity.x = 0
		linear_velocity.z = 0
	
	# Movement input
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()
	var basis_yaw = Transform3D(Basis(Vector3.UP, rotation.y), Vector3.ZERO)
	var move_dir = (basis_yaw * input_dir).normalized()
	var vel = linear_velocity
	vel.x = move_dir.x * current_speed
	vel.z = move_dir.z * current_speed

	# Grappling system
	if is_grappling and grapple_point:
		var dir_to_grapple = grapple_point - global_transform.origin
		var dist = dir_to_grapple.length()
		gravity_scale = 0
		if dist < 1.5:
			is_grappling = false
			linear_velocity = Vector3.ZERO
		else:
			vel = dir_to_grapple.normalized() * drag_speed
	linear_velocity = vel

	gravity_scale = 2

func apply_fall_damage(damage):
	health -= damage
	if health <= 0:
		die()
		print("YOU DIED")

func die():
	linear_velocity = Vector3.ZERO
	is_ragdoll = true
	death_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
