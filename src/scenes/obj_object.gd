extends CharacterBody2D

var belt_velocity = Vector2.ZERO
var n = 0
var skip_next_collision = false

func _process(_delta):
	n += 1
	
	if n % 6:
		return
	
	var a = Lib.get_first_group_member("main_tilemaps") as TileMap
	
	var cell_coord = a.local_to_map(self.position)
	var tile = a.get_cell_tile_data(1, cell_coord)
	
	if not tile:
		# no belt below? *poof*
		self.queue_free()
		return
	
	if tile.get_custom_data("t_type") == "belt":
		handle_belt(a, cell_coord)

func handle_belt(a: TileMap, cell_coord: Vector2i):
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
	
	if not self.test_move(self.transform, v):
		self.position += v
		belt_velocity -= v

func copy_sprite_parameters(a: Sprite2D, b: Sprite2D):
	# b.texture = a.texture
	b.modulate = a.modulate
	b.visible = a.visible

func clear_sprite_parameters(a: Sprite2D):
	a.modulate = Color(1, 1, 1)
	a.visible = false

func copy_all_sprite_parameters(a: Node2D, b: Node2D):
	copy_sprite_parameters(a.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D, b.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D)
	copy_sprite_parameters(a.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D, b.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D)
	copy_sprite_parameters(a.get_node("Visuals/Parts/BottomRightSprite") as Sprite2D, b.get_node("Visuals/Parts/BottomRightSprite") as Sprite2D)
	copy_sprite_parameters(a.get_node("Visuals/Parts/TopRightSprite") as Sprite2D, b.get_node("Visuals/Parts/TopRightSprite") as Sprite2D)

func do_building_operation(building_name: String, secondary_offset: Vector2):
	print(building_name, ', ', secondary_offset)
	
	if skip_next_collision:
		print('  skip collision!')
		skip_next_collision = false
		return
	
	if building_name == "rotate":
		var tmp = Sprite2D.new()
		copy_sprite_parameters($Visuals/Parts/BottomLeftSprite, tmp)
		copy_sprite_parameters($Visuals/Parts/BottomRightSprite, $Visuals/Parts/BottomLeftSprite)
		copy_sprite_parameters($Visuals/Parts/TopRightSprite, $Visuals/Parts/BottomRightSprite)
		copy_sprite_parameters($Visuals/Parts/TopLeftSprite, $Visuals/Parts/TopRightSprite)
		copy_sprite_parameters(tmp, $Visuals/Parts/TopLeftSprite)
	elif building_name == "split_vertical":
		var other = load("res://scenes/obj_object.tscn").instantiate()
		other.n = self.n
		other.skip_next_collision = true
		other.global_position += self.global_position + secondary_offset
		copy_all_sprite_parameters(self, other)
		self.call_deferred("add_sibling", other)
		
		# TODO: always assumes that obj entered on the left
		
		clear_sprite_parameters($Visuals/Parts/BottomRightSprite)
		clear_sprite_parameters($Visuals/Parts/TopRightSprite)
		clear_sprite_parameters(other.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D)
		clear_sprite_parameters(other.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D)
	elif building_name == "split_horizontal":
		var other = load("res://scenes/obj_object.tscn").instantiate()
		other.n = self.n
		other.skip_next_collision = true
		other.global_position += self.global_position + secondary_offset
		copy_all_sprite_parameters(self, other)
		self.call_deferred("add_sibling", other)
		
		# TODO: always assumes that obj entered on the left
		
		clear_sprite_parameters($Visuals/Parts/BottomRightSprite)
		clear_sprite_parameters($Visuals/Parts/BottomLeftSprite)
		clear_sprite_parameters(other.get_node("Visuals/Parts/TopRightSprite") as Sprite2D)
		clear_sprite_parameters(other.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D)
