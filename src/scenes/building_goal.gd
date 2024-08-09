extends Node2D

var completed = false

func get_obj_object(object_area: Area2D):
	var parent = object_area.get_parent() as Node2D
	
	if not parent:
		return null
	
	if not "do_building_operation" in parent:
		return null
	
	return parent

func _on_left_area_area_entered(area):
	var tmp = get_obj_object(area)
	
	if not tmp:
		print("what entered?")
		assert(false)
		return
	
	if completed:
		return
	
	if Lib.get_obj_object_description($Visuals/Parts) == Lib.get_obj_object_description(tmp.get_node("Visuals/Parts")):
		completed = true
		$Visuals/Sprite2D.frame += 1

