class_name DungeonGenerator

extends Node

@export var config: DungeonGenConfig

var _rng := RandomNumberGenerator.new()
var _active_map_data: MapData

class GenerationResult:
	var rooms: Array[Rect2i] = []
	var room_centers: Array[Vector2i] = []

func generate_into(map_data: MapData) -> GenerationResult:
	_rng.randomize()

	if config == null:
		push_error("DungeonGenerator: config is null.")
		return GenerationResult.new()

	if config.room_placer == null:
		push_error("DungeonGenerator: config.room_placer is null.")
		return GenerationResult.new()

	if config.corridor_carver == null:
		push_error("DungeonGenerator: config.corridor_carver is null.")
		return GenerationResult.new()
		
	if config.room_connector == null:
		push_error("DungeonGenerator: config.room_connector is null.")
		_active_map_data = null
		return GenerationResult.new()

	_active_map_data = map_data

	_fill_all_walls(map_data)

	var result := GenerationResult.new()

	var rooms: Array[Rect2i] = config.room_placer.create_rooms(map_data, _rng, config)
	
	for r in rooms:
		_carve_room(r)
		result.rooms.append(r)
		result.room_centers.append(_rect_center(r))

	var edges: Array[RoomEdge] = config.room_connector.build_edges(_rng, result.room_centers)

	config.corridor_carver.carve_edges(
		map_data,
		_rng,
		config,
		result.room_centers,
		edges,
		Callable(self, "_set_floor")
	)

	_active_map_data = null
	return result

# ------------------------------------------------------------
# Baseline fill
# ------------------------------------------------------------

func _fill_all_walls(map_data: MapData) -> void:
	for y in range(map_data.height):
		for x in range(map_data.width):
			map_data.set_cell(Vector2i(x, y), config.wall_kind, config.wall_visual)

# ------------------------------------------------------------
# Carving
# ------------------------------------------------------------

func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			_set_floor(Vector2i(x, y))

func _set_floor(pos: Vector2i) -> void:
	if _active_map_data == null:
		return
	if not _active_map_data.is_in_bounds(pos):
		return
	_active_map_data.set_cell(pos, config.floor_kind, config.floor_visual)

func _rect_center(room: Rect2i) -> Vector2i:
	return Vector2i(room.position.x + int(room.size.x / 2), room.position.y + int(room.size.y / 2))
