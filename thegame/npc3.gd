extends CharacterBody3D

@export var wander_radius: float = 10.0      # How far the NPC can wander from start
@export var speed: float = 2.5               # Wander speed
@export var wait_time_min: float = 1.0       # Minimum wait time
@export var wait_time_max: float = 3.0       # Maximum wait time
@export var rotation_speed: float = 5.0      # How fast NPC turns

var start_position: Vector3
var target_position: Vector3
var waiting: bool = false
var player: Node3D = null

@onready var detection_area = $DetectionArea

@onready var speech_bubble = $SpeechBubble

func say(text: String):
	if speech_bubble:
		speech_bubble.show_message(text)


func _ready():
	start_position = global_transform.origin
	_pick_new_target()
	if detection_area:
		detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
		detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player:
		# Stop movement
		velocity = Vector3.ZERO
		# Smoothly rotate to face the player
		_face_target(player.global_transform.origin, delta)
		return  # Skip move_and_slide

	if waiting:
		return
	
	# Wander movement
	var direction = target_position - global_transform.origin
	direction.y = 0
	if direction.length() > 0.1:
		velocity = direction.normalized() * speed
		_face_target(target_position, delta)
	move_and_slide()

	# Check if reached target
	if global_transform.origin.distance_to(target_position) < 0.5:
		waiting = true
		velocity = Vector3.ZERO
		await get_tree().create_timer(randf_range(wait_time_min, wait_time_max)).timeout
		_pick_new_target()
		waiting = false

func _pick_new_target():
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	target_position = start_position + random_offset

func _face_target(target: Vector3, delta: float):
	var direction = target - global_transform.origin
	direction.y = 0
	if direction.length() == 0:
		return
	var current_rot = global_transform.basis.get_rotation_quaternion()
	var target_rot = Quaternion(Vector3.UP, atan2(direction.x, direction.z))
	var new_rot = current_rot.slerp(target_rot, delta * rotation_speed)
	global_transform.basis = Basis(new_rot)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		say("Climbing sheer walls is easy! Just continually jump while facing the wall!")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		say("Stick to the walls with 'W A S D'!")
