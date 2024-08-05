extends Node2D

var belt_velocity = Vector2.ZERO
var n = 0

func _process(_delta):
	n += 1
	
	if n % 6:
		return
	
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
	
	if not rotated and not flip_h: # >
		belt_velocity.x = 5
	elif not rotated and flip_h: # <
		belt_velocity.x = -5
	elif rotated and not flip_h: # ^
		belt_velocity.y = -5
	elif rotated and flip_h: # v
		belt_velocity.y = 5
	# else:
	# 	?!
	
	var v = Vector2.ZERO
	
	if belt_velocity.x > 0:
		v.x = 1
	elif belt_velocity.x < 0:
		v.x = -1
	
	if belt_velocity.y > 0:
		v.y = 1
	elif belt_velocity.y < 0:
		v.y = -1
	
	self.position += v
	
	belt_velocity -= v
