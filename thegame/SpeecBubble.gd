extends Node3D

@export var lifetime := 3.0  # How long the bubble stays visible

@onready var label = $Label3D

func show_message(text: String):
	label.text = text
	visible = true
	# Auto-hide after lifetime
	await get_tree().create_timer(lifetime).timeout
	visible = false
