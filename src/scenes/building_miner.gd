extends Node2D

@export_enum("object", "paint") var resource_type = "object"
@export var paint_color: Color = Color(1, 0, 0)
@export var is_dual_size: bool = false
@export var mine_interval_sec: float = 1.4

var is_blocked = false

func _ready():
	$Timer.wait_time = mine_interval_sec

func _on_timer_timeout():
	if is_blocked:
		return
	
	var other
	
	if resource_type == "object":
		other = load("res://scenes/obj_object.tscn").instantiate()
	elif resource_type == "paint":
		other = load("res://scenes/obj_paint.tscn").instantiate()
		other.set_paint_color(paint_color)
	
	other.global_position += self.global_position
	Lib.get_first_group_member("objects_containers").add_child(other)

func _on_left_area_area_entered(area):
	is_blocked = true

func _on_left_area_area_exited(area):
	is_blocked = false

