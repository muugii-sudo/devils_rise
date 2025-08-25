extends CharacterBody3D

var arm_speed = 5
var drag_speed = 0
var hit_check = Vector3.ZERO
var player = null
var extending = false
var retracting = false
var max_distance = 20
var direction = Vector3.ZERO
var start_position = Vector3.ZERO
var is_grappling = false
var grapple_point: Vector3
@onready var cam := $Camera3D
@onready var arm_ray = $RayCast3D 

func _ready():
	player = get_parent()
	start_position = global_transform.origin
	
func _input(event):
	if event.is_action_pressed("rmb"):
		if arm_ray.is_colliding():
			var dist = global_position.distance_to(arm_ray.get_collision_point())
			if dist < max_distance:
				grapple_point = arm_ray.get_collision_point()
				is_grappling = true
	if event.is_action_released("rmb"):
		is_grappling = false
		
func _integrate_forces(state):
	if is_grappling:
		var dir = (grapple_point - global_position).normalized()
		get_parent().linear_velocity = dir * arm_speed
		if global_position.distance_to(grapple_point) < 2:
			is_grappling = false
	
func _extend():
	if extending or retracting:
		return
	extending = true
	start_position = global_transform.origin
	direction = -player.cam.global_transform.basis.z.normalized()
	
func start_retracting():
	retracting = true
	
func _physics_process(delta):
	if extending:
		var motion = direction * arm_speed * delta
		var collision = move_and_collide(motion)
		if collision:
			extending = false
			start_retracting()
			return
		if global_transform.origin.distance_to(start_position) >= max_distance:
			extending = false
			start_retracting()
	elif retracting:
		var hand_position = player.global_transform.origin + Vector3.ZERO
		var back_dir = (hand_position - global_transform.origin).normalized()
		var motion = back_dir * arm_speed * delta
		if global_transform.origin.distance_to(hand_position) >= 1:
			retracting = false
			global_transform.origin = hand_position
		else:
			global_transform.origin += motion
