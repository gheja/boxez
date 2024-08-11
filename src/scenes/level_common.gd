extends Node2D

@onready var level_lock_tilemap = $LevelLockTileMap as TileMap
@onready var tilemap = $TileMap as TileMap

var belt_count = 0

func unlock_level(n: int):
	for cell_coord in level_lock_tilemap.get_used_cells(0):
		var cell = level_lock_tilemap.get_cell_tile_data(0, cell_coord)
		
		if cell.get_custom_data("t_level") == n:
			level_lock_tilemap.set_cell(0, cell_coord, -1)

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
func copy_cell_params(tilemap: TileMap, source_cell_coord, dest_cell_coord):
	var source_id = tilemap.get_cell_source_id(1, source_cell_coord)
	var atlas_coord = tilemap.get_cell_atlas_coords(1, source_cell_coord)
	var alternative_tile = tilemap.get_cell_alternative_tile(1, source_cell_coord)
	
	# this does not work on layer 1 for some reason...
	tilemap.set_cell(1, dest_cell_coord, source_id, atlas_coord, alternative_tile)

func do_destroy(cell_coord: Vector2i):
	tilemap.set_cell(1, cell_coord, -1)

func do_build_belt(cell_coord: Vector2i, rotation: int):
	if rotation % 360 == 0:
		copy_cell_params(tilemap, Vector2i(0, -2), cell_coord)
	elif rotation % 360 == 90:
		copy_cell_params(tilemap, Vector2i(1, -2), cell_coord)
	if rotation % 360 == 180:
		copy_cell_params(tilemap, Vector2i(2, -2), cell_coord)
	if rotation % 360 == 270:
		copy_cell_params(tilemap, Vector2i(3, -2), cell_coord)
		
	tilemap.set_cell(1, cell_coord, 0)
	
func use_tool(cell_coord: Vector2i, tool: String, rotation: int):
	print(cell_coord, ", ", tool, ", ", rotation)
	if not is_cell_editable(cell_coord):
		return
	
	if tool == "destroy":
		do_destroy(cell_coord)
	elif tool == "belt":
		do_build_belt(cell_coord, rotation)

func remove_unlocked_objects(level_index: int):
	for cell_coord in level_lock_tilemap.get_used_cells(0):
		var cell = level_lock_tilemap.get_cell_tile_data(0, cell_coord)
		
		if cell.get_custom_data("t_level") != level_index:
			continue
		
		# "keep on start" layer
		var cell2 = level_lock_tilemap.get_cell_tile_data(1, cell_coord)
		
		if cell2:
			if cell2.get_custom_data("t_keep_on_start"):
				continue
		
		# belt
		if tilemap.get_cell_source_id(1, cell_coord):
			tilemap.set_cell(1, cell_coord, -1)
			belt_count += 1

func is_coord_locked(coord: Vector2):
	var cell_coord = level_lock_tilemap.local_to_map(coord)
	return is_cell_locked(cell_coord)

func _ready():
	# remove_unlocked_objects(1)
	unlock_level(1)
	level_lock_tilemap.modulate = Color.WHITE
	
	# level lock
	level_lock_tilemap.set_layer_enabled(0, true)
	
	# keep on start
	level_lock_tilemap.set_layer_enabled(1, false)
	
	Signals.connect("goal_completed", on_goal_completed)

func on_goal_completed(level_index: int):
	remove_unlocked_objects(level_index)
	unlock_level(level_index)
	Lib.get_first_group_member("main_overlays").pop_up_message("[center]New area unlocked[/center]")
