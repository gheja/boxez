extends Control

var scroll_direction = Vector2.ZERO

const SCROLL_EDGE_SIZE = 3

func _ready():
	Signals.connect("inactivity_changed", on_inactivity_changed)

func _process(delta):
	var pos = $CanvasLayer/Control123.get_local_mouse_position()
	
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
	$CanvasLayer.add_child(tmp)

func has_activity():
	Signals.emit_signal("inactivity_changed", false)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		has_activity()

func on_inactivity_changed(inactive: bool):
	if not inactive:
		$Timer.stop()
		$Timer.start()
		$AnimationPlayer.play("normal")
	else:
		$AnimationPlayer.play("run")

func _on_timer_timeout():
	Signals.emit_signal("inactivity_changed", true)
