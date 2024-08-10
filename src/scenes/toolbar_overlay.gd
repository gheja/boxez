extends Control

var level
var camera
var active_tool = "invalid"
var cursor_position
var cursor_cell_coord

func _ready():
	clear_hint()
	level = Lib.get_first_group_member("levels")
	camera = Lib.get_first_group_member("cameras")

func get_cell_coord(pos: Vector2):
	return Vector2(round((pos.x - 4) / 8), round((pos.y - 4) / 8))

func update_cursor():
	cursor_cell_coord = get_cell_coord(get_global_mouse_position() + camera.global_position - Vector2(32, 32)) 
	cursor_position = cursor_cell_coord * Vector2(8, 8) + Vector2(4, 4)
	
	if level.is_cell_editable(cursor_cell_coord):
		$CursorStuffs/BuildingOutlines.modulate = Color(1, 1, 1)
	else:
		$CursorStuffs/BuildingOutlines.modulate = Color(1, 0, 0)
	
	$CursorStuffs.global_position = cursor_position - camera.global_position + Vector2(32, 32)

func use_tool():
	level.use_tool(cursor_cell_coord, active_tool, $CursorStuffs.rotation_degrees)

func _process(_delta):
	update_cursor()

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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.as_text_physical_keycode() == "R" and event.pressed:
			$CursorStuffs.rotation_degrees += 90

func _on_building_outlines_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			use_tool()
