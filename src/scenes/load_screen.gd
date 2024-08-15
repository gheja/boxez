extends Node2D

func go_to_menu():
	AudioManager.start_menu_music()
	get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")

func _ready():
	if OS.get_name() == "Windows":
		go_to_menu.call_deferred()

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		go_to_menu()
