class_name IlluminationMap

extends RefCounted

var width: int
var height: int

# One byte per cell for LightLevel.*
var level: PackedByteArray

func _init(w: int, h: int, base_level: int) -> void:
	width = w
	height = h

	var count := width * height
	level = PackedByteArray()
	level.resize(count)

	fill(base_level)

func _idx(pos: Vector2i) -> int:
	return pos.y * width + pos.x

func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < width and pos.y < height

func fill(base_level: int) -> void:
	var v := LightLevel.clamp_level(base_level)
	for i in range(level.size()):
		level[i] = v

func get_level(pos: Vector2i) -> int:
	if not in_bounds(pos):
		return LightLevel.SUPERNATURAL_DARKNESS
	return int(level[_idx(pos)])

func set_level_max(pos: Vector2i, new_level: int) -> void:
	if not in_bounds(pos):
		return
	var i := _idx(pos)
	var v := LightLevel.clamp_level(new_level)
	if v > int(level[i]):
		level[i] = v

func set_level_min(pos: Vector2i, new_level: int) -> void:
	if not in_bounds(pos):
		return
	var i := _idx(pos)
	var v := LightLevel.clamp_level(new_level)
	if v < int(level[i]):
		level[i] = v
