class_name Map

extends Node2D

@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
var gen_result: DungeonGenerator.GenerationResult

@export var map_width: int = 80
@export var map_height: int = 45

@export var floor_layer: TileMapLayer
@export var wall_layer: TileMapLayer

@export var fog_layer: TileMapLayer

# Vision configuration (player for now)
# TODO: support others later
# TODO: make bright and dim radius source dependent, take off map?
@export var bright_radius: int = 4
@export var dim_radius_extra: int = 4  # dim extends bright by this many squares

# TODO: Move this to a definition and resource
@export var fog_source_id: int = 1
@export var fog_full_atlas_coords: Vector2i = Vector2i.ZERO
@export var fog_dim_light_atlas_coords: Vector2i = Vector2i.ZERO
@export var fog_dim_atlas_coords: Vector2i = Vector2i.ZERO
@export var fog_alternative_tile: int = 0

var _previous_player_visible: Array[Vector2i] = []

var registry: TileVisualRegistry
var map_data: MapData


func _ready() -> void:
	randomize()

	registry = TileVisualRegistry.new()
	map_data = MapData.new(map_width, map_height, registry)
	
	gen_result = dungeon_generator.generate_into(map_data)

	render_all()
	_initialize_fog()


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


func _initialize_fog() -> void:
	if fog_layer == null:
		return

	fog_layer.clear()

	for y in range(map_data.height):
		for x in range(map_data.width):
			_draw_fog_full(Vector2i(x, y))


# Apply fog-of-war based on the given observer's vision state.
# This is intentionally "player-oriented rendering": enemies can have VisionState too,
# but only the player VisionState drives fog visuals.
func apply_player_vision(vision: VisionState, newly_visible: Array[Vector2i]) -> void:
	if fog_layer == null or vision == null:
		return

	# Refresh cells that used to be visible (likely becoming dim now).
	for cell in _previous_player_visible:
		_refresh_fog_cell(vision, cell)

	# Refresh cells that are visible now (becoming clear now).
	for cell in newly_visible:
		_refresh_fog_cell(vision, cell)

	_previous_player_visible = newly_visible


func _refresh_fog_cell(vision: VisionState, cell: Vector2i) -> void:
	if not map_data.is_in_bounds(cell):
		return
		
	# Critical: if not currently visible, ignore light_level entirely.
	if not vision.is_visible(cell):
		if not vision.is_explored(cell):
			_draw_fog_full(cell)
		else:
			_draw_fog_dim(cell)
		return

	# From here down, the cell is visible, so light_level is meaningful.
	var lvl := vision.get_perceived_light(cell)

	# Visible in dim light: show dim-light overlay
	if lvl == LightLevel.DIM:
		fog_layer.set_cell(cell, fog_source_id, fog_dim_light_atlas_coords, fog_alternative_tile)
		return

	# Visible in normal/bright: clear
	fog_layer.erase_cell(cell)


func _draw_fog_full(cell: Vector2i) -> void:
	fog_layer.set_cell(cell, fog_source_id, fog_full_atlas_coords, fog_alternative_tile)


func _draw_fog_dim(cell: Vector2i) -> void:
	fog_layer.set_cell(cell, fog_source_id, fog_dim_atlas_coords, fog_alternative_tile)


func get_player_spawn() -> Vector2i:
	if gen_result != null and not gen_result.room_centers.is_empty():
		return gen_result.room_centers[0]
	return Vector2i(map_width / 2, map_height / 2)
