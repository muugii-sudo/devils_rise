extends Node3D

var waiting: bool = false
var player: Node3D = null

@onready var detection_area = $DetectionArea

@onready var speech_bubble = $SpeechBubble

func say(text: String):
	if speech_bubble:
		speech_bubble.show_message(text)


func _ready():
	if detection_area:
		detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
		detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player:
		# Stop movement
		# velocity = Vector3.ZERO
		# Smoothly rotate to face the player
		##_face_target(player.global_transform.origin, delta)
		return  # Skip move_and_slide

	if waiting:
		return
	
	

	# Check if reached target
	#if global_transform.origin.distance_to(target_position) < 0.5:
		#waiting = true
		#velocity = Vector3.ZERO
		#await get_tree().create_timer(randf_range(wait_time_min, wait_time_max)).timeout
		#_pick_new_target()
		#waiting = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		say("Hello BITHC")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		say("BYE BYE poopoo")
