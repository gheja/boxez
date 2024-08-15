extends Control

var credits_texts = [
	"Code:\n  Gabor Heja",
	"Graphics:\n  Gabor Heja",
	"Music:\n  Kim Lightyear",
	"Sounds:\n  Kenney",
	"\n- Click to start -",
	"\n -Click to start- ",
	"\n- Click to start -",
]

var credits_index = -1

func _ready():
	$RichTextLabel.text = ""

func _on_timer_timeout():
	credits_index += 1
	
	if credits_index == credits_texts.size():
		credits_index = 0
	
	$RichTextLabel.text = credits_texts[credits_index]
