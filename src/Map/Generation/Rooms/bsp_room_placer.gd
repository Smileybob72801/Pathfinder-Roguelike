class_name BspRoomPlacer

extends RoomPlacer

@export_category("BSP")
@export var min_leaf_size: int = 14
@export var max_depth: int = 5
@export var split_bias: float = 0.55 # >0.5 favors splitting along the longer axis

@export_category("Rooms Inside Leaves")
@export var room_margin: int = 1        # empty border inside leaf
@export var allow_non_square_rooms: bool = true

func create_rooms(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig) -> Array[Rect2i]:
	var bounds := Rect2i(
		config.padding_from_border,
		config.padding_from_border,
		map_data.width - (config.padding_from_border * 2),
		map_data.height - (config.padding_from_border * 2)
	)

	if bounds.size.x <= config.room_min_size or bounds.size.y <= config.room_min_size:
		return []

	var leaves: Array[Rect2i] = []
	_split_leaf(rng, bounds, 0, leaves)

	var rooms: Array[Rect2i] = []
	for leaf in leaves:
		var room_v: Variant = _make_room_in_leaf(map_data, rng, config, leaf)
		if room_v == null:
			continue
		rooms.append(room_v as Rect2i)

	return rooms

func _split_leaf(rng: RandomNumberGenerator, leaf: Rect2i, depth: int, out_leaves: Array[Rect2i]) -> void:
	if depth >= max_depth:
		out_leaves.append(leaf)
		return

	var can_split_h := leaf.size.y >= (min_leaf_size * 2)
	var can_split_v := leaf.size.x >= (min_leaf_size * 2)

	if not can_split_h and not can_split_v:
		out_leaves.append(leaf)
		return

	var split_h: bool
	if can_split_h and can_split_v:
		# Prefer splitting the longer axis, with a bias.
		if leaf.size.x > leaf.size.y:
			split_h = rng.randf() > split_bias
		elif leaf.size.y > leaf.size.x:
			split_h = rng.randf() < split_bias
		else:
			split_h = rng.randf() < 0.5
	else:
		split_h = can_split_h

	if split_h:
		var split_y := rng.randi_range(min_leaf_size, leaf.size.y - min_leaf_size)
		var top := Rect2i(leaf.position.x, leaf.position.y, leaf.size.x, split_y)
		var bottom := Rect2i(leaf.position.x, leaf.position.y + split_y, leaf.size.x, leaf.size.y - split_y)
		_split_leaf(rng, top, depth + 1, out_leaves)
		_split_leaf(rng, bottom, depth + 1, out_leaves)
	else:
		var split_x := rng.randi_range(min_leaf_size, leaf.size.x - min_leaf_size)
		var left := Rect2i(leaf.position.x, leaf.position.y, split_x, leaf.size.y)
		var right := Rect2i(leaf.position.x + split_x, leaf.position.y, leaf.size.x - split_x, leaf.size.y)
		_split_leaf(rng, left, depth + 1, out_leaves)
		_split_leaf(rng, right, depth + 1, out_leaves)

func _make_room_in_leaf(map_data: MapData, rng: RandomNumberGenerator, config: DungeonGenConfig, leaf: Rect2i) -> Variant:
	var inner := Rect2i(
		leaf.position.x + room_margin,
		leaf.position.y + room_margin,
		leaf.size.x - (room_margin * 2),
		leaf.size.y - (room_margin * 2)
	)

	if inner.size.x < config.room_min_size or inner.size.y < config.room_min_size:
		return null

	var max_w := mini(inner.size.x, config.room_max_size)
	var max_h := mini(inner.size.y, config.room_max_size)

	var w := rng.randi_range(config.room_min_size, max_w)
	var h := rng.randi_range(config.room_min_size, max_h)

	if not allow_non_square_rooms:
		var s := mini(w, h)
		w = s
		h = s

	var max_x := inner.position.x + inner.size.x - w
	var max_y := inner.position.y + inner.size.y - h
	if max_x < inner.position.x or max_y < inner.position.y:
		return null

	var x := rng.randi_range(inner.position.x, max_x)
	var y := rng.randi_range(inner.position.y, max_y)

	return Rect2i(x, y, w, h)
