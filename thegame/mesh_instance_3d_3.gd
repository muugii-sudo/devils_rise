extends MeshInstance3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action("rmb"):
		position.z -= 0.5
	if event.is_action_released("rmb"):
		position.z = -0.5
