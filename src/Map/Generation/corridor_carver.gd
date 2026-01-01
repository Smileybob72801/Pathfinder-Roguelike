class_name CorridorCarver

extends Resource

func connect_rooms(
	map_data: MapData,
	rng: RandomNumberGenerator,
	config: DungeonGenConfig,
	room_centers: Array[Vector2i],
	carve_floor: Callable
) -> void:
	push_error("CorridorCarver.connect_rooms() not implemented")
