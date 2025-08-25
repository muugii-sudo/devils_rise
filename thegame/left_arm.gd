extends CharacterBody3D

@export var arm_speed := 15.0
@export var max_distance := 20.0

var player = null
var extending := false
var retracting := false
var start_position := Vector3.ZERO
var direction := Vector3.ZERO
var grapple_point: Vector3

@onready var ray = $RayCast3D

func _ready():
	player = get_parent()
	start_position = global_transform.origin

func extend():
	if extending or retracting:
		return
	extending = true
	start_position = global_transform.origin
	direction = -player.cam.global_transform.basis.z.normalized()

func _physics_process(delta):
	if extending:
		var motion = direction * arm_speed * delta
		var collision = move_and_collide(motion)
		if collision:
			extending = false
			retracting = true
			grapple_point = collision.get_position()
			player.is_grappling = true
			player.grapple_point = grapple_point
			return

		if global_transform.origin.distance_to(start_position) >= max_distance:
			extending = false
			retracting = true

	elif retracting:
		var hand_pos = player.global_transform.origin + Vector3.ZERO
		var back_dir = (hand_pos - global_transform.origin).normalized()
		var motion = back_dir * arm_speed * delta
		if global_transform.origin.distance_to(hand_pos) <= 0.5:
			retracting = false
			global_transform.origin = hand_pos
		else:
			global_transform.origin += motion
