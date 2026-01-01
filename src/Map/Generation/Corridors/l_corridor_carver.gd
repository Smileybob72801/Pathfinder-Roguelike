class_name LCorridorCarver

extends CorridorCarver

func carve_edges(
	map_data: MapData,
	rng: RandomNumberGenerator,
	config: DungeonGenConfig,
	room_centers: Array[Vector2i],
	edges: Array[RoomEdge],
	carve_floor: Callable
) -> void:
	for e in edges:
		var start: Vector2i = room_centers[e.a]
		var end: Vector2i = room_centers[e.b]
		_tunnel_between(map_data, rng, start, end, carve_floor)

func _tunnel_between(
	map_data: MapData,
	rng: RandomNumberGenerator,
	start: Vector2i,
	end: Vector2i,
	carve_floor: Callable
) -> void:
	if rng.randf() < 0.5:
		_tunnel_horizontal(map_data, start.y, start.x, end.x, carve_floor)
		_tunnel_vertical(map_data, end.x, start.y, end.y, carve_floor)
	else:
		_tunnel_vertical(map_data, start.x, start.y, end.y, carve_floor)
		_tunnel_horizontal(map_data, end.y, start.x, end.x, carve_floor)

func _tunnel_horizontal(map_data: MapData, y: int, x_start: int, x_end: int, carve_floor: Callable) -> void:
	var x_min: int = mini(x_start, x_end)
	var x_max: int = maxi(x_start, x_end)
	for x in range(x_min, x_max + 1):
		carve_floor.call(Vector2i(x, y))

func _tunnel_vertical(map_data: MapData, x: int, y_start: int, y_end: int, carve_floor: Callable) -> void:
	var y_min: int = mini(y_start, y_end)
	var y_max: int = maxi(y_start, y_end)
	for y in range(y_min, y_max + 1):
		carve_floor.call(Vector2i(x, y))
