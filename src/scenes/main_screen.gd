extends Node2D

var level

func _ready():
	level = Lib.get_first_group_member("levels")
	
	var marker = Lib.get_first_group_member("camera_start_positions")
	if marker:
		$Camera2D.global_position = marker.global_position

func _process(_delta):
	# var a = $MainOverlay.scroll_direction
	var a = Vector2.ZERO
	a.x += Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	a.y += Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	a.x = clamp(a.x, -1.0, 1.0)
	a.y = clamp(a.y, -1.0, 1.0)
	
	var target_position = $Camera2D.position + a
	
	if not level.is_coord_locked(target_position):
		$Camera2D.position = target_position
