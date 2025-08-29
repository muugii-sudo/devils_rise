extends Control

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://node_3d.tscn")
