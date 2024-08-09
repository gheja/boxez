extends Node2D

var level

func _ready():
	level = Lib.get_first_group_member("levels")

func _process(_delta):
	var target_position = $Camera2D.position + $Camera2D/MainOverlay.scroll_direction
	
	if not level.is_coord_locked(target_position):
		$Camera2D.position = target_position
