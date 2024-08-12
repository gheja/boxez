extends Node2D

@export var level_index: int = 0

func _ready():
	Signals.connect("goal_completed", on_goal_completed)

func on_goal_completed(next_level_index: int):
	if next_level_index == level_index:
		$AnimationPlayer.play("run")
