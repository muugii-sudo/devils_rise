extends Node3D

@export var wander_radius: float = 10.0      # How far the NPC can wander from start
@export var speed: float = 2.5               # Wander speed
@export var wait_time_min: float = 1.0       # Minimum wait time
@export var wait_time_max: float = 3.0       # Maximum wait time
@export var rotation_speed: float = 5.0      # How fast NPC turns

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

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		say("Hello BITHC")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		say("BYE BYE poopoo")
