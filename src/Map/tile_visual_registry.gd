class_name TileVisualRegistry

extends RefCounted

var _sets: Array[TileVisualDefinition] = []
var _id_by_path: Dictionary = {} # path -> id


func intern(set_res: TileVisualDefinition) -> int:
	# Resources loaded from .tres have resource_path set.
	var path := set_res.resource_path
	if path != "" and _id_by_path.has(path):
		return _id_by_path[path]

	var id := _sets.size()
	_sets.append(set_res)

	if path != "":
		_id_by_path[path] = id

	return id


func get_set(id: int) -> TileVisualDefinition:
	if id < 0 or id >= _sets.size():
		return null
	return _sets[id]
