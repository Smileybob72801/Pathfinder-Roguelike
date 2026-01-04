class_name BspRoomPlacer

extends RoomPlacer

@export_category("Variety")
@export_range(0.0, 1.0, 0.01) var blank_leaf_chance: float = 0.10  # 15% leaves produce no room
# Choose room size as a fraction of the leaf's inner space (more variety than uniform absolute sizes)
@export_range(0.0, 1.0, 0.01) var fill_min: float = 0.35 # room uses at least 45% of inner width/height
@export_range(0.0, 1.0, 0.01) var fill_max: float = 0.90 # room uses up to 95% of inner width/height

@export_range(0.0, 1.0, 0.01) var stop_split_chance: float = 0.10

# Bias toward smaller or larger rooms within the [fill_min..fill_max] range:
# 0.0 -> tends larger, 0.5 -> neutral, 1.0 -> tends smaller
@export_range(0.0, 1.0, 0.01) var small_room_bias: float = 0.50

@export_category("BSP")
@export var min_leaf_size: int = 12
@export var max_depth: int = 6
@export var split_bias: float = 0.65 # >0.5 favors splitting along the longer axis
@export var split_margin: int = 2


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
	if depth > 0 and stop_split_chance > 0.0 and rng.randf() < stop_split_chance:
		out_leaves.append(leaf)
		return
		
	if depth >= max_depth:
		out_leaves.append(leaf)
		return

	var min_child: int = min_leaf_size + split_margin
	var can_split_h: bool = leaf.size.y >= (min_child * 2)
	var can_split_v: bool = leaf.size.x >= (min_child * 2)

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
		var split_y: int = rng.randi_range(min_child, leaf.size.y - min_child)
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
	# Optional: allow blank leaves
	if blank_leaf_chance > 0.0 and rng.randf() < blank_leaf_chance:
		return null

	var inner := Rect2i(
		leaf.position.x + room_margin,
		leaf.position.y + room_margin,
		leaf.size.x - (room_margin * 2),
		leaf.size.y - (room_margin * 2)
	)

	if inner.size.x < config.room_min_size or inner.size.y < config.room_min_size:
		return null

	# Compute room size relative to leaf size (this is the main variety driver)
	var max_w_cap: int = mini(inner.size.x, config.room_max_size)
	var max_h_cap: int = mini(inner.size.y, config.room_max_size)

	var w: int = _pick_dim_from_fill(rng, inner.size.x, config.room_min_size, max_w_cap)
	var h: int = _pick_dim_from_fill(rng, inner.size.y, config.room_min_size, max_h_cap)

	if not allow_non_square_rooms:
		var s: int = mini(w, h)
		w = s
		h = s

	var max_x: int = inner.position.x + inner.size.x - w
	var max_y: int = inner.position.y + inner.size.y - h
	if max_x < inner.position.x or max_y < inner.position.y:
		return null

	var x: int = rng.randi_range(inner.position.x, max_x)
	var y: int = rng.randi_range(inner.position.y, max_y)

	return Rect2i(x, y, w, h)


func _pick_dim_from_fill(rng: RandomNumberGenerator, inner_dim: int, min_dim: int, max_dim: int) -> int:
	# Fill fraction in [fill_min..fill_max], biased by small_room_bias
	var t: float = rng.randf()

	# Bias curve: small_room_bias < 0.5 -> tends larger, >0.5 -> tends smaller
	# Keep it simple and predictable: use power curve around 0.5
	var bias: float = clampf(small_room_bias, 0.0, 1.0)
	if bias < 0.5:
		# Larger rooms more likely
		var p_big: float = lerpf(0.6, 3.0, (0.5 - bias) / 0.5)
		t = pow(t, 1.0 / p_big)
	elif bias > 0.5:
		# Smaller rooms more likely
		var p_small: float = lerpf(0.6, 3.0, (bias - 0.5) / 0.5)
		t = pow(t, p_small)

	var fill: float = lerpf(fill_min, fill_max, t)
	var target: int = int(round(inner_dim * fill))

	# Still respect your global min/max constraints
	target = maxi(target, min_dim)
	target = mini(target, max_dim)
	return target
