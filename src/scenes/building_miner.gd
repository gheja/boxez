extends Node2D

func _on_timer_timeout():
	var other = load("res://scenes/obj_object.tscn").instantiate()
	other.global_position += self.global_position
	Lib.get_first_group_member("objects_containers").add_child(other)
