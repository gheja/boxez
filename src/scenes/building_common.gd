extends Node2D

@export var operation = "invalid"

func area_entered(object_area: Area2D, secondary_offset: Vector2):
	var parent = object_area.get_parent() as Node2D
	
	if not parent:
		return
	
	if not "do_building_operation" in parent:
		return
	
	parent.do_building_operation(self.operation, secondary_offset)

func _on_left_area_area_entered(area: Area2D):
	area_entered(area, $RightArea/CollisionShape2D_2.global_position - $LeftArea/CollisionShape2D_1.global_position)

func _on_right_area_area_entered(area: Area2D):
	area_entered(area, $LeftArea/CollisionShape2D_1.global_position - $RightArea/CollisionShape2D_2.global_position)
