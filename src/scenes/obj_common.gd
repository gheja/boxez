extends CharacterBody2D

@export_enum("object", "paint") var resource_type = "object"

var belt_velocity = Vector2.ZERO
var held_at_building = false
var debug_name = "?"
var mining_name = "?"
var is_currenty_in_building = false

func _ready():
	debug_name = "obj-" + str(Lib.get_unique_index())
	# print("[new] ", debug_name)

func _process(_delta):
	if not Lib.belt_step_sync():
		return
	
	# get the tile below the object on the "belts" layer
	var a = Lib.get_first_group_member("main_tilemaps") as TileMap
	var cell_coord = a.local_to_map(self.position)
	var tile = a.get_cell_tile_data(1, cell_coord)
	
	# if there is nothing below the object (i.e. no belt)
	if not tile:
		var effect = load("res://scenes/effects/effect_poof.tscn").instantiate()
		effect.global_position = self.global_position
		Lib.get_first_group_member("effects_containers").add_child(effect)
	
		self.queue_free()
		
		return
	
	# only move if not being held at a building
	if not held_at_building:
		if tile.get_custom_data("t_type") == "belt":
			handle_belt(a, cell_coord)

func handle_belt(a: TileMap, cell_coord: Vector2i):
	var alt_id = a.get_cell_alternative_tile(1, cell_coord)
	
	var flip_v = alt_id & TileSetAtlasSource.TRANSFORM_FLIP_V > 0
	var flip_h = alt_id & TileSetAtlasSource.TRANSFORM_FLIP_H > 0
	var rotated = alt_id & TileSetAtlasSource.TRANSFORM_TRANSPOSE > 0
	
	if not rotated and not flip_h: # ^
		belt_velocity.y = -5
	elif not rotated and flip_h: # v
		belt_velocity.y = 5
	elif rotated and not flip_h: # <
		belt_velocity.x = -5
	elif rotated and flip_h: # >
		belt_velocity.x = 5
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

func copy_sprite_parameters(a: Sprite2D, b: Sprite2D, copy_only_visible: bool = false):
	if copy_only_visible and not a.visible:
		return
	
	# b.texture = a.texture
	b.modulate = a.modulate
	b.visible = a.visible

func clear_sprite_parameters(a: Sprite2D):
	a.modulate = Color(1, 1, 1)
	a.visible = false

func copy_all_sprite_parameters(a: Node2D, b: Node2D, copy_only_visible: bool = false):
	copy_sprite_parameters(a.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D,     b.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D,     copy_only_visible)
	copy_sprite_parameters(a.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D,  b.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D,  copy_only_visible)
	copy_sprite_parameters(a.get_node("Visuals/Parts/BottomRightSprite") as Sprite2D, b.get_node("Visuals/Parts/BottomRightSprite") as Sprite2D, copy_only_visible)
	copy_sprite_parameters(a.get_node("Visuals/Parts/TopRightSprite") as Sprite2D,    b.get_node("Visuals/Parts/TopRightSprite") as Sprite2D,    copy_only_visible)

func apply_color_to_part(a: Sprite2D, color: Color):
	a.modulate = Lib.color3_add_clamp_special(a.modulate, color)

func do_building_operation(building_name: String, secondary_offset: Vector2):
	# print(debug_name, ': single, ', building_name, ', ', secondary_offset)
	
	if resource_type == "paint":
		if building_name == "merge":
			self.held_at_building = true
		
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
		other.is_currenty_in_building = true
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
		other.is_currenty_in_building = true
		other.global_position += self.global_position + secondary_offset
		copy_all_sprite_parameters(self, other)
		self.call_deferred("add_sibling", other)
		
		# TODO: always assumes that obj entered on the left
		
		clear_sprite_parameters($Visuals/Parts/BottomRightSprite)
		clear_sprite_parameters($Visuals/Parts/BottomLeftSprite)
		clear_sprite_parameters(other.get_node("Visuals/Parts/TopRightSprite") as Sprite2D)
		clear_sprite_parameters(other.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D)
	elif building_name == "merge" or building_name == "stack":
		self.held_at_building = true

func do_building_dual_operation(operation: String, other: CharacterBody2D):
	var left = self
	var right = other
	
	# print(debug_name, ': dual, ', operation, ',', left, ',', right)
	
	if operation == "merge":
		# when mixed, make sure that the left object is the "object"
		if left.resource_type == "paint" and right.resource_type == "object":
			var tmp
			
			# print('  swap: ', left.debug_name, ', ', right.debug_name)
			
			# swap positions
			tmp = left.global_position
			left.global_position = right.global_position
			right.global_position = tmp
			
			# swap the "pointers"
			tmp = left
			left = right
			right = tmp
			
		if left.resource_type == "object" and right.resource_type == "object":
			# TODO: this will get all visible parts from the right object and copy to
			# the left object without checking if there is collision
			
			# NOTE: the merger updates the left object and keeps that, then destroys
			# the right object. the copy_...() functions have source and destination
			# order in the function call (which is the opposite)
			
			copy_all_sprite_parameters(right, left, true)
			
		elif left.resource_type == "object" and right.resource_type == "paint":
			var color = right.get_paint_color()
			apply_color_to_part(left.get_node("Visuals/Parts/TopLeftSprite") as Sprite2D, color)
			apply_color_to_part(left.get_node("Visuals/Parts/BottomLeftSprite") as Sprite2D, color)
			apply_color_to_part(left.get_node("Visuals/Parts/BottomRightSprite") as Sprite2D, color)
			apply_color_to_part(left.get_node("Visuals/Parts/TopRightSprite") as Sprite2D, color)
			
		elif left.resource_type == "paint" and right.resource_type == "paint":
			left.set_paint_color(Lib.color3_add_clamp(left.get_paint_color(), right.get_paint_color()))
	
	right.queue_free()
	left.held_at_building = false
	
func set_paint_color(color: Color):
	$Visuals/Parts/PaintSprite.modulate = color

func get_paint_color():
	return $Visuals/Parts/PaintSprite.modulate
