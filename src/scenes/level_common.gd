extends Node2D

@export var demo_mode = false

@onready var level_lock_tilemap = $LevelLockTileMap as TileMap
@onready var fog_tilemap = $FogTileMap as TileMap
@onready var tilemap = $TileMap as TileMap
var toolbar_overlay: Control
var belt_count = 0

func unlock_level(n: int):
	var effect_scene = load("res://scenes/effects/effect_area_reveal.tscn")
	var effect
	var pos
	var container = Lib.get_first_group_member("effects_containers")
	
	for cell_coord in level_lock_tilemap.get_used_cells(0):
		var cell = level_lock_tilemap.get_cell_tile_data(0, cell_coord)
		
		if cell.get_custom_data("t_level") == n:
			pos = Vector2(cell_coord.x * 8 + 4, cell_coord.y * 8 + 4)
			level_lock_tilemap.set_cell(0, cell_coord, -1)
			fog_tilemap.set_cell(0, cell_coord, -1)
			
			effect = effect_scene.instantiate()
			effect.global_position = pos
			container.add_child.call_deferred(effect)

func is_cell_locked(cell_coord: Vector2i):
	# the cell is only filled when it is locked
	if level_lock_tilemap.get_cell_source_id(0, cell_coord) == -1:
		return false
	
	return true

func is_cell_editable(cell_coord: Vector2i):
	if is_cell_locked(cell_coord):
		return false
	
	# "keep on start" layer
	if level_lock_tilemap.get_cell_tile_data(1, cell_coord):
		return
	
	return true

func is_tool_usable_on_cell(cell_coord: Vector2i, tool: String, rotation: int):
	if not is_cell_editable(cell_coord):
		return false
	
	if tool == "belt":
		if get_building_on_cell(cell_coord):
			return false
	
	elif tool == "split_vertical" or tool == "split_horizontal" or tool == "merge":
		var left_position = Vector2(cell_coord.x * 8 + 4, cell_coord.y * 8 + 4)
		var right_position = left_position + Vector2(8, 0).rotated(rotation)
		var right_cell_coord = Vector2i(round(right_position.x - 4) / 8, round(right_position.y - 4) / 8)
		
		if not is_cell_editable(right_cell_coord):
			return false
	
	return true

func copy_cell_params(tilemap: TileMap, source_cell_coord, dest_cell_coord, source_cell_layer: int = 1, dest_cell_layer: int = 1):
	var source_id = tilemap.get_cell_source_id(source_cell_layer, source_cell_coord)
	var atlas_coord = tilemap.get_cell_atlas_coords(source_cell_layer, source_cell_coord)
	var alternative_tile = tilemap.get_cell_alternative_tile(source_cell_layer, source_cell_coord)
	
	tilemap.set_cell(dest_cell_layer, dest_cell_coord, source_id, atlas_coord, alternative_tile)

func get_building_on_cell(cell_coord: Vector2i):
	var pos = Vector2(cell_coord.x * 8 + 4, cell_coord.y * 8 + 4)
	
	for obj in $BuildingsContainer.get_children():
		if obj.position == pos:
			return obj
		
		if obj.is_dual_size:
			var right_position = obj.position + Vector2(8, 0).rotated(obj.rotation)
			
			if Lib.lazy_equal_vector2(right_position, pos):
				return obj
	
	return null

func do_destroy(cell_coord: Vector2i):
	tilemap.set_cell(1, cell_coord, -1)
	
	var building = get_building_on_cell(cell_coord)
	if building:
		var left_position = building.position
		var left_cell_coord = Vector2i((left_position.x - 4) / 8, (left_position.y - 4) / 8)
		
		tilemap.set_cell(1, left_cell_coord, -1)
		
		if building.is_dual_size:
			var right_position = building.position + Vector2(8, 0).rotated(building.rotation)
			var right_cell_coord = Vector2i(round(right_position.x - 4) / 8, round(right_position.y - 4) / 8)
			
			tilemap.set_cell(1, right_cell_coord, -1)
		
		building.queue_free()

func do_build_belt(cell_coord: Vector2i, rotation: int):
	if rotation % 360 == 0:
		copy_cell_params(tilemap, Vector2i(0, -2), cell_coord)
	elif rotation % 360 == 90:
		copy_cell_params(tilemap, Vector2i(1, -2), cell_coord)
	if rotation % 360 == 180:
		copy_cell_params(tilemap, Vector2i(2, -2), cell_coord)
	if rotation % 360 == 270:
		copy_cell_params(tilemap, Vector2i(3, -2), cell_coord)

func do_build_building(cell_coord: Vector2i, rotation: int, scene_name: String, variation: int):
	var pos = Vector2(cell_coord.x * 8 + 4, cell_coord.y * 8 + 4)
	
	var scene_full_name = "res://scenes/building_" + scene_name + ".tscn"
	var building = load(scene_full_name).instantiate()
	building.global_position = pos
	building.rotation_degrees = rotation
	
	do_destroy(cell_coord)
	
	if building.is_dual_size:
		var right_position = building.position + Vector2(8, 0).rotated(building.rotation)
		var right_cell_coord = Vector2i(round(right_position.x - 4) / 8, round(right_position.y - 4) / 8)
		
		do_destroy(right_cell_coord)
		
		do_build_belt(right_cell_coord, rotation)
	
	# if there is a building above the right cell destroying it would delete the
	# belt if we built it earlier
	do_build_belt(cell_coord, rotation)
	
	$BuildingsContainer.add_child(building)

func use_tool(cell_coord: Vector2i, tool: String, rotation: int):
	print(cell_coord, ", ", tool, ", ", rotation)
	if not is_tool_usable_on_cell(cell_coord, tool, rotation):
		return
	
	if tool == "destroy":
		do_destroy(cell_coord)
		AudioManager.play_sound(3, 0.7, 1.5)
	elif tool == "rotate":
		do_build_building(cell_coord, rotation, "rotate", 0)
		AudioManager.play_sound(2, 0.5, 0.8)
	elif tool == "split_vertical":
		do_build_building(cell_coord, rotation, "split_vertical", 0)
		AudioManager.play_sound(2, 0.5, 0.8)
	elif tool == "split_horizontal": # TODO: this should be a variant!!!
		do_build_building(cell_coord, rotation, "split_horizontal", 0)
		AudioManager.play_sound(2, 0.5, 0.8)
	elif tool == "merge":
		do_build_building(cell_coord, rotation, "merge", 0)
		AudioManager.play_sound(2, 0.5, 0.8)
	elif tool == "belt":
		do_build_belt(cell_coord, rotation)
		AudioManager.play_sound(2, 1.3, 1.6, 0.5)

func remove_unlocked_objects():
	for cell_coord in level_lock_tilemap.get_used_cells(0):
		# "keep on start" layer
		var cell2 = level_lock_tilemap.get_cell_tile_data(1, cell_coord)
		
		if cell2:
			if cell2.get_custom_data("t_keep_on_start"):
				continue
		
		do_destroy(cell_coord)

func is_coord_locked(coord: Vector2):
	var cell_coord = level_lock_tilemap.local_to_map(coord)
	return is_cell_locked(cell_coord)

func init_fog_tilemap():
	for coord in level_lock_tilemap.get_used_cells(0):
		copy_cell_params(fog_tilemap, Vector2(0, -3), coord, 0, 0)

func _ready():
	Lib.demo_mode = demo_mode
	
	if not Lib.demo_mode:
		toolbar_overlay = Lib.get_first_group_member("toolbar_overlays")
		
		init_fog_tilemap()
		remove_unlocked_objects()
		unlock_level(1)
		toolbar_overlay.unlock_tool("belt")
		level_lock_tilemap.modulate = Color.WHITE
	
	# level lock
	level_lock_tilemap.set_layer_enabled(0, false)
	
	# keep on start
	level_lock_tilemap.set_layer_enabled(1, false)
	
	Signals.connect("goal_completed", on_goal_completed)
	Signals.connect("active_tool_changed", on_active_tool_changed)

func on_goal_completed(level_index: int):
	if Lib.demo_mode:
		return
	
	unlock_level(level_index)
	
	if level_index == 2:
		toolbar_overlay.unlock_tool("split_horizontal")
	elif level_index == 3:
		toolbar_overlay.unlock_tool("merge")
	elif level_index == 4:
		toolbar_overlay.unlock_tool("rotate")
	elif level_index == 5:
		toolbar_overlay.unlock_tool("split_vertical")
	
	await get_tree().create_timer(0.75).timeout
	
	Lib.get_first_group_member("main_overlays").pop_up_message("New area unlocked!")

func on_active_tool_changed(name: String):
	if name == "none":
		$LevelLockTileMap.set_layer_enabled(1, false)
	else:
		$LevelLockTileMap.set_layer_enabled(1, true)
