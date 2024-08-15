extends Node

var menu_music_player: AudioStreamPlayer = null
var main_music_player: AudioStreamPlayer = null
var menu_music_volume = 1.0
var menu_music_volume_target = 1.0

var sounds = [
	preload("res://assets/music/kim_lightyear_-_illusion.ogg"), # 0
	preload("res://assets/music/kim_lightyear_-_voices_without_voices.ogg"),
	preload("res://assets/sounds/impactPlank_medium_000.ogg"),
	preload("res://assets/sounds/footstep_snow_000.ogg"),
	preload("res://assets/sounds/dropLeather.ogg"),
	preload("res://assets/sounds/kenney_beltHandle1_edited.ogg"),
	preload("res://assets/sounds/impactMining_001_edited.ogg"),
]

var volume_overrides = [
	0.3, 0.25,
	0.8, 0.3, 0.4, 1.33, 1.33
]

func play_sound(index, pitch_shift_min: float = 1.0, pitch_shift_max: float = 1.0, volume_multiplier: float = 1.0):
	var tmp = AudioStreamPlayer.new()
	tmp.stream = sounds[index]
	tmp.bus = "SFX"
	
	if volume_overrides.size() > index and volume_overrides[index] != null:
		tmp.volume_db = linear_to_db(volume_overrides[index] * volume_multiplier)
	else:
		tmp.volume_db = linear_to_db(1.0 * volume_multiplier)
	
	if pitch_shift_min != 1.0 or pitch_shift_max != 1.0:
		tmp.pitch_scale = randf_range(pitch_shift_min, pitch_shift_max)
	
	get_tree().root.call_deferred("add_child", tmp)
	
	tmp.play.call_deferred()

func _ready():
	menu_music_volume_target = 1.0
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = sounds[0]
	menu_music_player.volume_db = linear_to_db(volume_overrides[0])
	menu_music_player.bus = "Menu Music"
	
	get_tree().root.call_deferred("add_child", menu_music_player)

func start_menu_music():
	menu_music_player.play.call_deferred()

func start_main_music():
	main_music_player = AudioStreamPlayer.new()
	main_music_player.stream = sounds[1]
	main_music_player.volume_db = linear_to_db(volume_overrides[1])
	main_music_player.bus = "Menu Music"
	
	get_tree().root.call_deferred("add_child", main_music_player)
	
	main_music_player.play.call_deferred()

func fade_menu_music():
	menu_music_volume_target = 0.0

func process_menu_music():
	if not menu_music_player.playing:
		return
		
	menu_music_volume += (menu_music_volume_target - menu_music_volume) * 0.025
	
	if menu_music_volume < 0.001:
		menu_music_player.stop()
	
	menu_music_player.volume_db = linear_to_db(volume_overrides[0] * menu_music_volume)

func _process(_delta):
	process_menu_music()
