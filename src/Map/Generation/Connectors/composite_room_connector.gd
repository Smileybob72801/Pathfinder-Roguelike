class_name CompositeRoomConnector

extends RoomConnector

@export_category("Composite")
@export var base_connector: RoomConnector

# These are additive. Their edges are merged with the base, then de-duplicated.
@export var extra_connectors: Array[RoomConnector] = []

func build_edges(rng: RandomNumberGenerator, room_centers: Array[Vector2i]) -> Array[RoomEdge]:
	var merged: Array[RoomEdge] = []
	var used := {} # Dictionary as set: "a:b" -> true

	if room_centers.size() < 2:
		return merged

	if base_connector == null:
		push_error("CompositeRoomConnector: base_connector is null.")
		return merged

	_merge_edges(merged, used, base_connector.build_edges(rng, room_centers))

	for c in extra_connectors:
		if c == null:
			continue
		_merge_edges(merged, used, c.build_edges(rng, room_centers))

	return merged

func _merge_edges(out_edges: Array[RoomEdge], used: Dictionary, incoming: Array[RoomEdge]) -> void:
	for e in incoming:
		if e == null:
			continue

		var a: int = e.a
		var b: int = e.b

		if a == b:
			continue

		var lo: int = mini(a, b)
		var hi: int = maxi(a, b)

		var key: String = str(lo) + ":" + str(hi)
		if used.has(key):
			continue

		used[key] = true
		out_edges.append(RoomEdge.new(lo, hi))
