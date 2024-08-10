extends Control

func _ready():
	clear_hint()

func set_hint(s: String):
	$ButtonHelpText.text = s

func clear_hint():
	set_hint("")

func set_active_tool(s: String):
	for button in $HBoxContainer.get_children():
		if button.get_meta("building_type") == s:
			button.button_pressed = true
			button.release_focus()
		else:
			button.button_pressed = false
	
	print("tool: ", s)

func _on_button_belt_mouse_entered():
	set_hint("Conveyor belt")

func _on_button_rotate_mouse_entered():
	set_hint("Rotate")

func _on_button_split_vertical_mouse_entered():
	set_hint("Vertical splitter")

func _on_button_split_horizontal_mouse_entered():
	set_hint("Horizontal split.")

func _on_button_merge_mouse_entered():
	set_hint("Merger")

func _on_button_common_mouse_exited():
	clear_hint()

func _on_button_belt_pressed():
	set_active_tool("belt")

func _on_button_rotate_pressed():
	set_active_tool("rotate")

func _on_button_split_vertical_pressed():
	set_active_tool("split_vertical")

func _on_button_split_horizontal_pressed():
	set_active_tool("split_horizontal")

func _on_button_destroy_pressed():
	set_active_tool("destroy")

func _on_button_merge_pressed():
	set_active_tool("merge")

func _on_button_destroy_mouse_entered():
	set_hint("Remove")
