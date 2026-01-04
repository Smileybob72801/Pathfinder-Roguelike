class_name TorchSpawner

extends RefCounted

var _torches: Array[Vector2i] = []

func add_torch(cell: Vector2i) -> void:
	_torches.append(cell)

func clear() -> void:
	_torches.clear()

func get_torch_cells() -> Array[Vector2i]:
	return _torches.duplicate()

func build_light_sources(normal_radius: int, dim_radius: int) -> Array[LightSource]:
	var lights: Array[LightSource] = []
	for cell in _torches:
		lights.append(LightSource.new(cell, normal_radius, dim_radius))
	return lights
