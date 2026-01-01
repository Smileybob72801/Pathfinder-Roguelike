class_name LCorridorCarver

extends CorridorCarver

func connect_rooms(
	map_data: MapData,
	rng: RandomNumberGenerator,
	config: DungeonGenConfig,
	room_centers: Array[Vector2i],
	carve_floor: Callable
) -> void:
	if room_centers.size() < 2:
		return

	for i in range(1, room_centers.size()):
		_tunnel_between(map_data, rng, room_centers[i - 1], room_centers[i], carve_floor)

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
	var x_min := mini(x_start, x_end)
	var x_max := maxi(x_start, x_end)
	for x in range(x_min, x_max + 1):
		carve_floor.call(Vector2i(x, y))

func _tunnel_vertical(map_data: MapData, x: int, y_start: int, y_end: int, carve_floor: Callable) -> void:
	var y_min := mini(y_start, y_end)
	var y_max := maxi(y_start, y_end)
	for y in range(y_min, y_max + 1):
		carve_floor.call(Vector2i(x, y))
