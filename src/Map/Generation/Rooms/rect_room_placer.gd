class_name RectRoomPlacer

extends RoomPlacer

func create_rooms(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig) -> Array[Rect2i]:
	var rooms: Array[Rect2i] = []

	for _i in config.max_rooms:
		var room_v: Variant = _try_make_room(map_data, rng, config)

		if room_v == null:
			continue

		var room: Rect2i = room_v
		if _overlaps_any(room, rooms, config.room_spacing):
			continue

		rooms.append(room)

	return rooms

func _try_make_room(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig) -> Variant:
	var width := rng.randi_range(config.room_min_size, config.room_max_size)
	var height := rng.randi_range(config.room_min_size, config.room_max_size)

	var min_x := config.padding_from_border
	var min_y := config.padding_from_border
	var max_x := map_data.width - width - config.padding_from_border
	var max_y := map_data.height - height - config.padding_from_border

	if max_x <= min_x or max_y <= min_y:
		return null

	return Rect2i(
		rng.randi_range(min_x, max_x),
		rng.randi_range(min_y, max_y),
		width,
		height
	)

func _overlaps_any(candidate: Rect2i, existing: Array[Rect2i], margin: int) -> bool:
	var test := _inflated(candidate, margin)
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
