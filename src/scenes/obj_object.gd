extends Node2D

func _process(_delta):
	var a = Lib.get_first_group_member("main_tilemaps") as TileMap
	
	var cell_coord = a.local_to_map(self.position)
	var tile = a.get_cell_tile_data(1, cell_coord)
	
	if not tile:
		return
	
	if tile.get_custom_data("t_type") != "belt":
		return
	
	var alt_id = a.get_cell_alternative_tile(1, cell_coord)

	var flip_v = alt_id & TileSetAtlasSource.TRANSFORM_FLIP_V > 0
	var flip_h = alt_id & TileSetAtlasSource.TRANSFORM_FLIP_H > 0
	var rotated = alt_id & TileSetAtlasSource.TRANSFORM_TRANSPOSE > 0
	
	var v = Vector2.ZERO
	
	if not rotated and not flip_h: # >
		v = Vector2(1, 0)
	elif not rotated and flip_h: # <
		v = Vector2(-1, 0)
	elif rotated and not flip_h: # ^
		v = Vector2(0, -1)
	elif rotated and flip_h: # v
		v = Vector2(0, 1)
	# else:
	# 	?!
	self.position += v
