extends Node2D

@export var level_index_to_unlock: int = 0
@export var is_dual_size: bool = false


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
	var matched = false
	
	if not tmp:
		print("what entered?")
		assert(false)
		return
	
	if Lib.get_obj_object_description($Visuals/Parts) == Lib.get_obj_object_description(tmp.get_node("Visuals/Parts")):
		matched = true
	
	$Visuals/ResponseSprites/OkSprite.visible = matched
	$Visuals/ResponseSprites/FailSprite.visible = not matched
	$ResponseTimer.start()
	
	if matched:
		if completed:
			return
		
		var effect = load("res://scenes/effects/effect_goal_ok.tscn").instantiate()
		effect.global_position = self.global_position
		Lib.get_first_group_member("effects_containers").add_child(effect)
		
		AudioManager.play_sound(6, 1.0, 1.0)
		
		completed = true
		$Visuals/Sprite2D.frame += 1
		Signals.emit_signal("goal_completed", level_index_to_unlock)

func _on_response_timer_timeout():
	$Visuals/ResponseSprites/OkSprite.visible = false
	$Visuals/ResponseSprites/FailSprite.visible = false
