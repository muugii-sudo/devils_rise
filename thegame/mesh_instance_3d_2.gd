extends MeshInstance3D

var arm_speed = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action("lmb"):
		arm_speed = 1
	if event.is_action_released("lmb"):
		arm_speed = 0

	
