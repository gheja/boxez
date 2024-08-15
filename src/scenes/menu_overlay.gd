extends Control

var credits_texts = [
	"",
	"Code:\n  Gabor Heja",
	"Graphics:\n  Gabor Heja",
	"Music:\n  Kim Lightyear",
	"Sounds:\n  Kenney",
	"Font:\n  [d]esign",
	"\n[center]Lowrezjam 2024[/center]",
	"\n[center] -Click to start- [/center]",
	"\n[center]- Click to start -[/center]",
	"",
	"",
]

var credits_index = -1

func _ready():
	$CanvasLayer/RichTextLabel.text = ""

func _on_timer_timeout():
	credits_index += 1
	
	if credits_index == credits_texts.size():
		credits_index = 0
	
	$CanvasLayer/RichTextLabel.text = credits_texts[credits_index]
