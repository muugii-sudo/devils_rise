extends CharacterBody3D

var speed = 4.0

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	move_and_slide()
