class_name RectRoomPlacer
extends RoomPlacer

@export_category("Rect Rooms")
@export var max_rooms: int = 30

# Hard cap on how many random rooms we attempt to roll.
# This replaces the old "for _i in config.max_rooms" loop.
@export var placement_attempts: int = 120

# 0.0 = sparse (reject many valid placements), 1.0 = dense (accept all valid placements)
@export_range(0.0, 1.0, 0.01) var density_bias: float = 1.0

func create_rooms(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig) -> Array[Rect2i]:
	var rooms: Array[Rect2i] = []

	var attempts: int = maxi(placement_attempts, max_rooms)

	for _i in attempts:
		if rooms.size() >= max_rooms:
			break

		var room_v: Variant = _try_make_room(map_data, rng, config)
		if room_v == null:
			continue

		var room: Rect2i = room_v
		if _overlaps_any(room, rooms, config.room_spacing):
			continue

		# Density gate (lets you "thin out" rooms without changing sizes)
		if density_bias < 1.0 and rng.randf() > density_bias:
			continue

		rooms.append(room)

	return rooms

func _try_make_room(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig) -> Variant:
	var w: int = rng.randi_range(config.room_min_size, config.room_max_size)
	var h: int = rng.randi_range(config.room_min_size, config.room_max_size)

	var min_x: int = config.padding_from_border
	var min_y: int = config.padding_from_border
	var max_x: int = map_data.width - w - config.padding_from_border
	var max_y: int = map_data.height - h - config.padding_from_border

	if max_x <= min_x or max_y <= min_y:
		return null

	return Rect2i(
		rng.randi_range(min_x, max_x),
		rng.randi_range(min_y, max_y),
		w,
		h
	)

func _overlaps_any(candidate: Rect2i, existing: Array[Rect2i], margin: int) -> bool:
	var test: Rect2i = _inflated(candidate, margin)
	for r in existing:
		if test.intersects(r):
			return true
	return false

func _inflated(rect: Rect2i, margin: int) -> Rect2i:
	return Rect2i(
		rect.position.x - margin,
		rect.position.y - margin,
		rect.size.x + (margin * 2),
		rect.size.y + (margin * 2)
	)
