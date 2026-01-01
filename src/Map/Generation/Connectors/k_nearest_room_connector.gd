class_name KNearestRoomConnector

extends RoomConnector

@export_category("Connectivity")
# Number of nearest rooms to count as potential neighbors
@export var k: int = 3

# 0.0 = just the backbone (nearest), 1.0 = add lots of extra edges (loopier)
@export_range(0.0, 1.0, 0.01) var extra_density: float = 0.25

@export var max_extra_edges: int = 50

func build_edges(rng: RandomNumberGenerator, room_centers: Array[Vector2i]) -> Array[RoomEdge]:
	var edges: Array[RoomEdge] = []
	if room_centers.size() < 2:
		return edges

	var used := {} # Dictionary as set: "a:b" -> true

	# Backbone: connect each room to its nearest neighbor (produces a connected-ish graph in practice)
	for a in range(room_centers.size()):
		var b := _nearest_index(room_centers, a)
		if b == -1:
			continue
		_add_edge(edges, used, a, b)

	# Extra edges: choose from k-nearest candidates
	if extra_density <= 0.0 or max_extra_edges <= 0:
		return edges

	var extras_added: int = 0
	var attempts: int = 0
	var max_attempts: int = max_extra_edges * 20

	while extras_added < max_extra_edges and attempts < max_attempts:
		attempts += 1
		if rng.randf() > extra_density:
			continue

		var a: int = rng.randi_range(0, room_centers.size() - 1)
		var candidates: Array[int] = _k_nearest_indices(room_centers, a, k)

		if candidates.is_empty():
			continue

		var b: int = candidates[rng.randi_range(0, candidates.size() - 1)]
		if b == a:
			continue

		var added: bool = _add_edge(edges, used, a, b)
		if added:
			extras_added += 1

	return edges

func _add_edge(edges: Array[RoomEdge], used: Dictionary, a: int, b: int) -> bool:
	var lo: int = mini(a, b)
	var hi: int = maxi(a, b)
	var key: String = str(lo) + ":" + str(hi)

	if used.has(key):
		return false

	used[key] = true
	edges.append(RoomEdge.new(lo, hi))
	return true

func _nearest_index(points: Array[Vector2i], a: int) -> int:
	var best_i: int = -1
	var best_d2: int = 0

	for i in range(points.size()):
		if i == a:
			continue
		var d: Vector2i = points[i] - points[a]
		var d2: int = (d.x * d.x) + (d.y * d.y)

		if best_i == -1 or d2 < best_d2:
			best_i = i
			best_d2 = d2

	return best_i

func _k_nearest_indices(points: Array[Vector2i], a: int, k_count: int) -> Array[int]:
	var scored: Array[Dictionary] = []

	for i in range(points.size()):
		if i == a:
			continue
		var d: Vector2i = points[i] - points[a]
		var d2: int = (d.x * d.x) + (d.y * d.y)
		scored.append({ "i": i, "d2": d2 })

	scored.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		return int(x["d2"]) < int(y["d2"])
	)

	var out: Array[int] = []
	var limit: int = mini(k_count, scored.size())
	for j in range(limit):
		out.append(int(scored[j]["i"]))

	return out
