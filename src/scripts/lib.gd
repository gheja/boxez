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

func color_add_clamp(a: Color, b: Color):
	return Color(clamp(a.r + b.r, 0.0, 1.0), clamp(a.g + b.g, 0.0, 1.0), clamp(a.b + b.b, 0.0, 1.0), clamp(a.a + b.a, 0.0, 1.0))

# keeping alpha!
func color3_add_clamp(a: Color, b: Color):
	return Color(clamp(a.r + b.r, 0.0, 1.0), clamp(a.g + b.g, 0.0, 1.0), clamp(a.b + b.b, 0.0, 1.0), a.a)

# keeping alpha! handling unpainted
func color3_add_clamp_special(a: Color, b: Color):
	# if it is the initial (unpainted) color, let's ignore that
	if a.r < 0.9 and a.g < 0.9 and a.b < 0.9:
		a.r = 0.0
		a.g = 0.0
		a.b = 0.0
		# TODO: not sure if I should reset it to full opacity or not...
		# a.a = 1.0
	
	return Color(clamp(a.r + b.r, 0.0, 1.0), clamp(a.g + b.g, 0.0, 1.0), clamp(a.b + b.b, 0.0, 1.0), a.a)
