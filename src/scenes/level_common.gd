extends Node2D

@onready var level_lock_tilemap = $LevelLockTileMap as TileMap

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

func is_coord_locked(coord: Vector2):
	var cell_coord = level_lock_tilemap.local_to_map(coord)
	return is_cell_locked(cell_coord)

func _ready():
	unlock_level(1)
