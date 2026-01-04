class_name Grid

extends Object

const tile_size = Vector2i(32, 32)

static  func grid_to_world(grid_pos: Vector2i) -> Vector2i:
	var world_pos: Vector2i = grid_pos * tile_size
	return world_pos


static func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var grid_pos: Vector2i = world_pos / tile_size
	return grid_pos

## Pathfinder distance in squares:
## Every other diaginol counts as two squars
static func distance_pf(a: Vector2i, b: Vector2i) -> int:
	var dx: int = absi(b.x - a.x)
	var dy: int = absi(b.y - a.y)

	var diagonals: int = min(dx, dy)
	var straights: int = max(dx, dy) - diagonals

	# Every second diagonal costs 2 instead of 1
	var extra: int = diagonals >> 1

	return straights + diagonals + extra
