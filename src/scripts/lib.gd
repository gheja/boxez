extends Node

var frame_number = 0

func get_first_group_member(group_name):
	var members = get_tree().get_nodes_in_group(group_name)
	
	if members.size() == 0:
		print("Warning: No object matching group \"", group_name, "\", returning null.")
		return null
	
	return members[0]

func _process(delta):
	frame_number += 1

func belt_step_sync():
	# TODO: this might get out of sync if dropping frames, might need to reconsider
	
	if frame_number % 6 == 1:
		return true
	
	return false
