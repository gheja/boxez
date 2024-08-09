extends Control

var scroll_direction = Vector2.ZERO

const SCROLL_EDGE_SIZE = 3

func _ready():
	pass # Replace with function body.

func _process(delta):
	var pos = get_local_mouse_position()
	
	scroll_direction = Vector2.ZERO
	
	if pos.x < SCROLL_EDGE_SIZE:
		scroll_direction.x = -1
	elif pos.x > 64 - SCROLL_EDGE_SIZE:
		scroll_direction.x = +1
	
	if pos.y < SCROLL_EDGE_SIZE:
		scroll_direction.y = -1
	elif pos.y > 64 - SCROLL_EDGE_SIZE:
		scroll_direction.y = +1

func pop_up_message(message):
	var tmp = load("res://scenes/message_overlay.tscn").instantiate()
	tmp.pop_up_message(message)
	self.add_child(tmp)
