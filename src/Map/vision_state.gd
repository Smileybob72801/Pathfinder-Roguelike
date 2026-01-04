class_name VisionState

extends RefCounted

var width: int
var height: int

var visible: PackedByteArray
var explored: PackedByteArray = PackedByteArray()

# 0..4, using LightLevel constants
var perceived_light: PackedByteArray

func _init(w: int, h: int, track_explored: bool) -> void:
	width = w
	height = h

	var cell_count := width * height

	visible = PackedByteArray()
	visible.resize(cell_count)

	perceived_light = PackedByteArray()
	perceived_light.resize(cell_count)

	if track_explored:
		explored = PackedByteArray()
		explored.resize(cell_count)

func _idx(pos: Vector2i) -> int:
	return pos.y * width + pos.x

func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < width and pos.y < height

func clear_visible() -> void:
	for i in range(visible.size()):
		visible[i] = 0
		perceived_light[i] = LightLevel.SUPERNATURAL_DARKNESS

func set_visible(pos: Vector2i, value: bool) -> void:
	if not in_bounds(pos):
		return

	var i := _idx(pos)
	visible[i] = 1 if value else 0

	if value and explored.size() > 0:
		explored[i] = 1

func set_perceived_light(pos: Vector2i, level: int) -> void:
	if not in_bounds(pos):
		return
	perceived_light[_idx(pos)] = LightLevel.clamp_level(level)

func get_perceived_light(pos: Vector2i) -> int:
	if not in_bounds(pos):
		return LightLevel.SUPERNATURAL_DARKNESS
	return int(perceived_light[_idx(pos)])

func is_visible(pos: Vector2i) -> bool:
	if not in_bounds(pos):
		return false
	return visible[_idx(pos)] == 1

func is_explored(pos: Vector2i) -> bool:
	if explored.size() <= 0:
		return false
	if not in_bounds(pos):
		return false
	return explored[_idx(pos)] == 1
