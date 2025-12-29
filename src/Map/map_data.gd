class_name MapData

extends RefCounted

enum TileKind {
	FLOOR,
	WALL
}

enum TileVisual {
	FLOOR_FLAGSTONE,
	WALL_STONE_BRICK
}

const TILE_MECHANICS_DEFS := {
	TileKind.FLOOR: preload("res://assets/definitions/map/tiles/mechanics/tile_mechanics_definition_floor.tres"),
	TileKind.WALL: preload("res://assets/definitions/map/tiles/mechanics/tile_mechanics_definition_wall.tres"),
}

const TILE_VISUAL_DEFS := {
	TileVisual.FLOOR_FLAGSTONE: preload("res://assets/definitions/map/tiles/visuals/floor_flagstone.tres"),
	TileVisual.WALL_STONE_BRICK: preload("res://assets/definitions/map/tiles/visuals/wall_stone_brick.tres")
}

var width: int
var height: int

# Mechanics, visuals, and variants are separate
var kinds: PackedInt32Array
var visual_set_ids: PackedInt32Array
var variants: PackedInt32Array

var visuals: TileVisualRegistry

func _init(w: int, h: int, registry: TileVisualRegistry) -> void:
	width = w
	height = h
	visuals = registry
	_initialize_tiles()


func _initialize_tiles() -> void:
	var cell_count := width * height

	kinds = PackedInt32Array()
	visual_set_ids = PackedInt32Array()
	variants = PackedInt32Array()
	
	kinds.resize(cell_count)
	visual_set_ids.resize(cell_count)
	variants.resize(cell_count)
	
	# Sentinel initialization (makes missing visuals obvious)
	for i in range(cell_count):
		kinds[i] = TileKind.FLOOR
		visual_set_ids[i] = -1
		variants[i] = 0

	# Demo: fill the whole map with flagstone floor (variant 0 for now)
	for y in range(height):
		for x in range(width):
			set_cell(Vector2i(x, y), TileKind.FLOOR, TileVisual.FLOOR_FLAGSTONE)

	# Demo: wall segment (visible near origin)
	for x in range(1, 5):
		set_cell(Vector2i(x, 3), TileKind.WALL, TileVisual.WALL_STONE_BRICK, 0)


func set_cell(pos: Vector2i, kind: TileKind, visual: TileVisual, variant: int = -1) -> void:
	if not is_in_bounds(pos):
		return

	var def: TileVisualDefinition = TILE_VISUAL_DEFS[visual]
	var set_id := visuals.intern(def)

	var i := grid_to_index(pos)
	kinds[i] = kind
	visual_set_ids[i] = set_id

	var option_count: int = def.atlas_coords_options.size()
	if option_count <= 0:
		variants[i] = 0
	elif variant >= 0:
		variants[i] = variant % option_count
	else:
		variants[i] = randi() % option_count


func get_kind(pos: Vector2i) -> int:
	if not is_in_bounds(pos):
		return -1
	return kinds[grid_to_index(pos)]


func get_visual_set_id(pos: Vector2i) -> int:
	if not is_in_bounds(pos):
		return -1
	return visual_set_ids[grid_to_index(pos)]


func get_variant(pos: Vector2i) -> int:
	if not is_in_bounds(pos):
		return 0
	return variants[grid_to_index(pos)]


func is_walkable(pos: Vector2i) -> bool:
	if not is_in_bounds(pos):
		return false
	var def: TileMechanicsDefinition = TILE_MECHANICS_DEFS[get_kind(pos)]
	return def.is_walkable


func is_transparent(pos: Vector2i) -> bool:
	if not is_in_bounds(pos):
		return false
	var def: TileMechanicsDefinition = TILE_MECHANICS_DEFS[get_kind(pos)]
	return def.is_transparent


func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


func grid_to_index(pos: Vector2i) -> int:
	return pos.y * width + pos.x
