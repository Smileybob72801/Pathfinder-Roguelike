class_name DrunkWalkCorridorCarver

extends CorridorCarver

@export_category("Drunk Walk")
@export var max_steps_per_connection: int = 500
@export var prefer_axis_weight: float = 0.75

func carve_edges(
	map_data: MapData,
	rng: RandomNumberGenerator,
	config: DungeonGenConfig,
	room_centers: Array[Vector2i],
	edges: Array[RoomEdge],
	carve_floor: Callable
) -> void:
	for e in edges:
		var width: int = _pick_width(rng, config)
		_connect(map_data, rng, room_centers[e.a], room_centers[e.b], width, carve_floor)

func _pick_width(rng: RandomNumberGenerator, config: DungeonGenConfig) -> int:
	if config.corridor_widths == null:
		return 1
	return maxi(1, config.corridor_widths.pick(rng))

func _connect(
	map_data: MapData,
	rng: RandomNumberGenerator,
	start: Vector2i,
	target: Vector2i,
	width: int,
	carve_floor: Callable
) -> void:
	var pos: Vector2i = start
	_carve_blob(map_data, pos, width, carve_floor)

	var steps: int = 0
	while pos != target and steps < max_steps_per_connection:
		steps += 1

		var dx: int = target.x - pos.x
		var dy: int = target.y - pos.y

		var move_x: bool = abs(dx) > 0
		var move_y: bool = abs(dy) > 0

		var step: Vector2i = Vector2i.ZERO

		if move_x and move_y:
			if rng.randf() < prefer_axis_weight:
				if abs(dx) >= abs(dy):
					step.x = _signi(dx)
				else:
					step.y = _signi(dy)
			else:
				if rng.randf() < 0.5:
					step.x = _signi(dx)
				else:
					step.y = _signi(dy)
		elif move_x:
			step.x = _signi(dx)
		elif move_y:
			step.y = _signi(dy)
		else:
			break

		var next: Vector2i = pos + step
		if not map_data.is_in_bounds(next):
			break

		pos = next
		_carve_blob(map_data, pos, width, carve_floor)

func _carve_blob(map_data: MapData, center: Vector2i, width: int, carve_floor: Callable) -> void:
	var half_low: int = int(width / 2)
	var half_high: int = width - half_low - 1

	for y in range(center.y - half_low, center.y + half_high + 1):
		for x in range(center.x - half_low, center.x + half_high + 1):
			var p: Vector2i = Vector2i(x, y)
			if map_data.is_in_bounds(p):
				carve_floor.call(p)

func _signi(v: int) -> int:
	if v < 0:
		return -1
	if v > 0:
		return 1
	return 0
