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
		_connect(map_data, rng, room_centers[e.a], room_centers[e.b], carve_floor)

func _connect(
	map_data: MapData,
	rng: RandomNumberGenerator,
	start: Vector2i,
	target: Vector2i,
	carve_floor: Callable
) -> void:
	var pos: Vector2i = start
	carve_floor.call(pos)

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
		carve_floor.call(pos)

func _signi(v: int) -> int:
	if v < 0:
		return -1
	if v > 0:
		return 1
	return 0
