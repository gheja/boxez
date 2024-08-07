extends Node2D

var is_blocked = false

func _on_timer_timeout():
	if is_blocked:
		return
	
	var other = load("res://scenes/obj_object.tscn").instantiate()
	other.global_position += self.global_position
	Lib.get_first_group_member("objects_containers").add_child(other)

func _on_left_area_area_entered(area):
	is_blocked = true

func _on_left_area_area_exited(area):
	is_blocked = false
