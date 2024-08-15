extends Control

var level
var camera
var active_tool = "none"
var active_tool_rotation = 0
var cursor_position
var cursor_cell_coord

var valid_tools = [ "none", "belt", "rotate", "split_vertical", "split_horizontal", "merge", "destroy" ]
var unlocked_tools = [ ]

func _ready():
	clear_hint()
	level = Lib.get_first_group_member("levels")
	camera = Lib.get_first_group_member("cameras")
	unlock_tool("none")
	unlock_tool("destroy")
	set_active_tool("none")

func get_cell_coord(pos: Vector2):
	return Vector2(round((pos.x - 4) / 8), round((pos.y - 4) / 8))

func update_cursor():
	cursor_cell_coord = get_cell_coord(get_global_mouse_position() + camera.global_position - Vector2(32, 32)) 
	cursor_position = cursor_cell_coord * Vector2(8, 8) + Vector2(4, 4)
	
	# if level.is_cell_editable(cursor_cell_coord):
	if level.is_tool_usable_on_cell(cursor_cell_coord, active_tool, active_tool_rotation):
		$CursorStuffs/BuildingOutlines.modulate = Color(1, 1, 1)
	else:
		$CursorStuffs/BuildingOutlines.modulate = Color(1, 0, 0)
	
	$CursorStuffs.global_position = cursor_position - camera.global_position + Vector2(32, 32)
	$CursorStuffs.rotation_degrees = active_tool_rotation
	
	if get_local_mouse_position().y > 52:
		$CursorStuffs.visible = false
	else:
		$CursorStuffs.visible = true

func use_tool():
	level.use_tool(cursor_cell_coord, active_tool, active_tool_rotation)

func _process(_delta):
	update_cursor()

func set_hint(s: String):
	$ButtonHelpText.text = s

func clear_hint():
	set_hint("")

func set_tool_button_status(button: Button, tool_name: String):
	button.disabled = not tool_name in unlocked_tools

func update_tool_buttons():
	set_tool_button_status($HBoxContainer/ButtonBelt, "belt")
	set_tool_button_status($HBoxContainer/ButtonRotate, "rotate")
	set_tool_button_status($HBoxContainer/ButtonSplitVertical, "split_vertical")
	set_tool_button_status($HBoxContainer/ButtonSplitHorizontal, "split_horizontal")
	set_tool_button_status($HBoxContainer/ButtonMerge, "merge")
	set_tool_button_status($HBoxContainer/ButtonDestroy, "destroy")

func unlock_tool(tool_name: String):
	assert(tool_name in valid_tools)
	if tool_name in unlocked_tools:
		return
	
	unlocked_tools.append(tool_name)
	
	update_tool_buttons()

func set_active_tool(s: String):
	if not s in unlocked_tools:
		return
	
	for button in $HBoxContainer.get_children():
		if button.get_meta("building_type") == s:
			button.button_pressed = true
			button.release_focus()
		else:
			button.button_pressed = false
	
	if active_tool != s:
		AudioManager.play_sound(5, 1.0, 1.0)
	
	active_tool = s
	
	$CursorStuffs/BuildingOutlines/BuildingBelt.visible = false
	$CursorStuffs/BuildingOutlines/Building1.visible = false
	$CursorStuffs/BuildingOutlines/Building2.visible = false
	$CursorStuffs/BuildingOutlines/Building3.visible = false
	$CursorStuffs/BuildingOutlines/BuildingDestroy.visible = false
	
	if active_tool == "belt":
		$CursorStuffs/BuildingOutlines/BuildingBelt.visible = true
	elif active_tool == "rotate":
		$CursorStuffs/BuildingOutlines/Building1.visible = true
	elif active_tool == "split_vertical" or active_tool == "split_horizontal":
		$CursorStuffs/BuildingOutlines/Building3.visible = true
	elif active_tool == "merge":
		$CursorStuffs/BuildingOutlines/Building2.visible = true
	elif active_tool == "destroy":
		$CursorStuffs/BuildingOutlines/BuildingDestroy.visible = true
	
	Signals.emit_signal("active_tool_changed", active_tool)

func _on_button_none_mouse_entered():
	set_hint("(none)")

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

func _on_button_none_pressed():
	set_active_tool("none")

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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.as_text_physical_keycode() == "1":
				set_active_tool("belt")
			elif event.as_text_physical_keycode() == "2":
				set_active_tool("rotate")
			elif event.as_text_physical_keycode() == "3":
				set_active_tool("split_vertical")
			elif event.as_text_physical_keycode() == "4":
				set_active_tool("split_horizontal")
			elif event.as_text_physical_keycode() == "5":
				set_active_tool("merge")
			elif event.as_text_physical_keycode() == "0" or event.as_text_physical_keycode() == "`":
				set_active_tool("destroy")
			elif event.as_text_physical_keycode() == "Q":
				set_active_tool("none")
			elif event.as_text_physical_keycode() == "R":
				if active_tool != "none" and active_tool != "destroy":
					active_tool_rotation += 90
					active_tool_rotation = active_tool_rotation % 360
					AudioManager.play_sound(4, 1.0, 1.25)

func _on_building_outlines_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			use_tool()
