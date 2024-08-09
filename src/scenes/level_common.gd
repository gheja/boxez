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
