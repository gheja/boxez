extends Node2D

@export var hint_text = "(none)"

func _ready():
	$CanvasLayer/RichTextLabel.text = "[center]" + hint_text + "[/center]"

func _process(_delta):
	var pos = get_global_mouse_position()
	
	if abs(pos.x - self.global_position.x) < 3 and abs(pos.y - self.global_position.y) < 3:
		$CanvasLayer.visible = true
	else:
		$CanvasLayer.visible = false
