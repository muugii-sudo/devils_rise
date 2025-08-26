extends CharacterBody3D

@export var arm_speed := 20
@export var max_distance := 15

var player = null
var extending := false
var retracting := false
var start_position := Vector3.ZERO
var direction := Vector3.ZERO
var grapple_point: Vector3
var rest_offset := Vector3.ZERO 

@onready var ray = $RayCast3D

func _ready():
	player = get_parent()
	rest_offset = player.to_local(global_transform.origin)

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
		var target_position = player.to_global(rest_offset)
		
		global_transform.origin = global_transform.origin.lerp(target_position, arm_speed * delta)
		
		if global_transform.origin.distance_to(target_position) <= 0.05:
			retracting = false
			global_transform.origin = target_position
