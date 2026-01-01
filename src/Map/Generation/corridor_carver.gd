class_name CorridorCarver

extends Resource

func carve_edges(
	map_data: MapData,
	rng: RandomNumberGenerator,
	config: DungeonGenConfig,
	room_centers: Array[Vector2i],
	edges: Array[RoomEdge],
	carve_floor: Callable
) -> void:
	push_error("CorridorCarver.carve_edges() not implemented")
