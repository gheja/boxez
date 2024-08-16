extends Node2D

@export var operation = "invalid"
@export var is_dual_size: bool = false

var last_object_left: CharacterBody2D = null
var last_object_right: CharacterBody2D = null

func _ready():
	if self.get_node("Visuals/IconSprite"):
		$Visuals/IconSprite.rotation = - self.rotation

func get_obj_object(object_area: Area2D):
	var parent = object_area.get_parent() as Node2D
	
	if not parent:
		return null
	
	if not "do_building_operation" in parent:
		return null
	
	return parent

func area_entered(obj_object: CharacterBody2D, secondary_offset: Vector2):
	obj_object.do_building_operation(self.operation, secondary_offset)

func handle_dual_input():
	if operation == "merge" or operation == "stack":
		if not last_object_left or not last_object_right:
			return
		
		last_object_left.do_building_dual_operation(self.operation, last_object_right)
		
		last_object_left = null
		last_object_right = null

func _on_left_area_area_entered(area: Area2D):
	var tmp = get_obj_object(area)
	
	if not tmp:
		print("what entered?")
		assert(false)
		return
	
	# print('left entered by ', tmp.debug_name)
	
	# to make sure we won't double-process it...
	if tmp.is_currenty_in_building:
		return
	
	tmp.is_currenty_in_building = true
	
	# snap the object to the center of the area to make sure it does not block both slots
	# but only if it is not the demo, following the object looks bad with the snapping
	if not Lib.demo_mode:
		tmp.global_position = $LeftArea/CollisionShape2D_1.global_position
	
	last_object_left = tmp
	area_entered(tmp, $RightArea/CollisionShape2D_2.global_position - $LeftArea/CollisionShape2D_1.global_position)
	handle_dual_input()

func _on_right_area_area_entered(area: Area2D):
	var tmp = get_obj_object(area)
	
	if not tmp:
		print("what entered?")
		assert(false)
		return
	
	# print('right entered by ', tmp.debug_name)
	
	# to make sure we won't double-process it...
	if tmp.is_currenty_in_building:
		return
	
	tmp.is_currenty_in_building = true
	
	# snap the object to the center of the area to make sure it does not block both slots
	# but only if it is not the demo, following the object looks bad with the snapping
	if not Lib.demo_mode:
		tmp.global_position = $RightArea/CollisionShape2D_2.global_position
	
	last_object_right = tmp
	area_entered(tmp, $LeftArea/CollisionShape2D_1.global_position - $RightArea/CollisionShape2D_2.global_position)
	handle_dual_input()

func _on_building_area_area_exited(area):
	var tmp = get_obj_object(area)
	
	if not tmp:
		print("what exited?")
		assert(false)
		return
	
	tmp.is_currenty_in_building = false
	
	if last_object_left == tmp:
		last_object_left = null
	
	if last_object_right == tmp:
		last_object_right = null
