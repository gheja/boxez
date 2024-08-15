extends Node2D

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		AudioManager.start_menu_music()
		get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")
