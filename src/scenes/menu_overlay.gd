extends Control

var transition_active = false
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

func do_transition():
	if transition_active:
		return
	
	transition_active = true
	
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
	AudioManager.start_main_music()
	AudioManager.fade_menu_music()

func has_activity():
	$LogoTimer.stop()
	$LogoTimer.start()
	$AnimationPlayer2.play("idle")

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		do_transition()
	
	if event is InputEventMouseMotion:
		has_activity()

func _on_logo_timer_timeout():
	$AnimationPlayer2.play("run")
