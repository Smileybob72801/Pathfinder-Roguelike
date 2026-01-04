class_name FieldOfView

extends RefCounted

# Recursive shadowcasting octant transforms
const _MULTIPLIERS := [
	[ 1, 0, 0, -1, -1, 0, 0,  1],
	[ 0, 1, -1, 0,  0, -1, 1, 0],
	[ 0, 1, 1,  0,  0, -1, -1, 0],
	[ 1, 0, 0,  1, -1,  0,  0, -1]
]

# Returns the list of cells that ended up visible (for render diffs)
func compute(map_data: MapData, vision: VisionState, origin: Vector2i, radius: int) -> Array[Vector2i]:
	vision.clear_visible()

	var visible_cells: Array[Vector2i] = []
	_set_visible(map_data, vision, origin, visible_cells)

	for o in range(8):
		_cast_light(
			map_data,
			vision,
			origin.x,
			origin.y,
			radius,
			1,
			1.0,
			0.0,
			_MULTIPLIERS[0][o],
			_MULTIPLIERS[1][o],
			_MULTIPLIERS[2][o],
			_MULTIPLIERS[3][o],
			visible_cells
		)

	return visible_cells


func compute_cells(map_data: MapData, origin: Vector2i, radius: int) -> Array[Vector2i]:
	var dummy := VisionState.new(map_data.width, map_data.height, false)
	return compute(map_data, dummy, origin, radius)


func _set_visible(map_data: MapData, vision: VisionState, pos: Vector2i, out_visible: Array[Vector2i]) -> void:
	if not map_data.is_in_bounds(pos):
		return
	if vision.is_visible(pos):
		return

	vision.set_visible(pos, true)
	out_visible.append(pos)


func _cast_light(
	map_data: MapData,
	vision: VisionState,
	ox: int,
	oy: int,
	radius: int,
	row: int,
	start_slope: float,
	end_slope: float,
	xx: int,
	xy: int,
	yx: int,
	yy: int,
	out_visible: Array[Vector2i]
) -> void:
	if start_slope < end_slope:
		return

	var next_start_slope := start_slope

	for i in range(row, radius + 1):
		var blocked := false
		var dy := -i

		for dx in range(-i, 1):
			var l_slope := (dx - 0.5) / (dy + 0.5)
			var r_slope := (dx + 0.5) / (dy - 0.5)

			if start_slope < r_slope:
				continue
			if end_slope > l_slope:
				break

			var ax := ox + dx * xx + dy * xy
			var ay := oy + dx * yx + dy * yy
			var pos := Vector2i(ax, ay)

			if not map_data.is_in_bounds(pos):
				continue

			# Opaque tiles are visible when they block a ray, so mark visible BEFORE checking transparency.
			if Grid.distance_pf(Vector2i.ZERO, Vector2i(dx, dy)) <= radius:
				_set_visible(map_data, vision, pos, out_visible)

			var is_opaque := not map_data.is_transparent(pos)

			if blocked:
				if is_opaque:
					next_start_slope = r_slope
					continue
				blocked = false
				start_slope = next_start_slope
			else:
				if is_opaque:
					blocked = true
					next_start_slope = r_slope
					_cast_light(map_data, vision, ox, oy, radius, i + 1, start_slope, l_slope, xx, xy, yx, yy, out_visible)

		if blocked:
			break
