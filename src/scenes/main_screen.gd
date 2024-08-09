extends Node2D

func _process(_delta):
	$Camera2D.position += $Camera2D/MainOverlay.scroll_direction
