extends Node2D

var level
var frame_number = 0


var demo_follows = [
	# [ frame_number, object_name ]
	[ 0, "mined,76,60", 1 ],
	[ 550, "mined,204,52", 3 ],
	[ 1100, "mined,292,52", 4 ],
	[ 1520, "mined,292,52", 1 ],
]
# 168 frames (2.8 sec * 60) between each mining
# 
var demo_end_frame = 2016
var demo_n = 168
var demo_loop_count = 0
var demo_mine_interval = floor(demo_end_frame / demo_n)


func _ready():
	process_priority = 5000
	level = Lib.get_first_group_member("levels")

func get_object(mining_name: String):
	for obj in level.get_node("ObjectsContainer").get_children():
		if not "mining_name" in obj:
			continue
		
		if obj.mining_name == mining_name:
			return obj
	
	return null

func _process(_delta):
	var last_params = null
	var last_object_name = ""
	frame_number += 1
	
	if frame_number % demo_end_frame == 0:
		demo_loop_count += 1
	
	for a in demo_follows:
		if a[0] > frame_number % demo_end_frame:
			break
		
		last_params = a
	
	if not last_params:
		return
	
	last_object_name = last_params[1] + "," + str(last_params[2] + demo_loop_count * demo_mine_interval)
	
	var obj = get_object(last_object_name)
	
	if obj:
		$Camera2D.global_position = obj.global_position
		# print(frame_number, " ", $Camera2D.global_position)
