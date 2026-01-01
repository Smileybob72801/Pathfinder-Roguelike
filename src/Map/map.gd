class_name Map

extends Node2D

@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
var gen_result: DungeonGenerator.GenerationResult

@export var map_width: int = 80
@export var map_height: int = 45

@export var floor_layer: TileMapLayer
@export var wall_layer: TileMapLayer

var registry: TileVisualRegistry
var map_data: MapData


func _ready() -> void:
	randomize()

	registry = TileVisualRegistry.new()
	map_data = MapData.new(map_width, map_height, registry)
	
	gen_result = dungeon_generator.generate_into(map_data)

	render_all()


func render_all() -> void:
	floor_layer.clear()
	wall_layer.clear()

	for y in range(map_data.height):
		for x in range(map_data.width):
			var cell := Vector2i(x, y)

			var kind := map_data.get_kind(cell)
			if kind == -1:
				continue

			# Draw a floor first...
			_draw_cell(floor_layer, cell)

			# ...then draw wall overlay if this cell is a wall
			if kind == MapData.TileKind.WALL:
				_draw_cell(wall_layer, cell)


func _draw_cell(layer: TileMapLayer, cell: Vector2i) -> void:
	var set_id := map_data.get_visual_set_id(cell)
	if set_id == -1:
		# DEBUG: Catch the sentinal value for an unset visual
		print("Missing visual set at cell: ", cell)
		return

	var def: TileVisualDefinition = registry.get_set(set_id)
	if def == null or def.atlas_coords_options.is_empty():
		return

	var variant: int = map_data.get_variant(cell)
	var coords: Vector2i = def.atlas_coords_options[variant % def.atlas_coords_options.size()]

	layer.set_cell(cell, def.source_id, coords, def.alternative_tile)


func get_player_spawn() -> Vector2i:
	if gen_result != null and not gen_result.room_centers.is_empty():
		return gen_result.room_centers[0]
	return Vector2i(map_width / 2, map_height / 2)
