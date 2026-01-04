class_name MstRoomConnector

extends RoomConnector

## Builds a Minimum Spanning Tree (MST) over room centers using Prim's algorithm.
## - Always returns a connected set of edges when room_centers.size() >= 2
## - Returns exactly (N - 1) edges for N rooms
## - No loops (cycles)

func build_edges(rng: RandomNumberGenerator, room_centers: Array[Vector2i]) -> Array[RoomEdge]:
	var edges: Array[RoomEdge] = []
	var n: int = room_centers.size()

	if n < 2:
		return edges

	# Prim's algorithm (O(n^2)) - simple and plenty fast for typical room counts.
	var in_tree: PackedByteArray = PackedByteArray()
	in_tree.resize(n)

	var best_cost: PackedInt32Array = PackedInt32Array()
	best_cost.resize(n)

	var best_parent: PackedInt32Array = PackedInt32Array()
	best_parent.resize(n)

	var i: int = 0
	while i < n:
		in_tree[i] = 0
		best_cost[i] = 2147483647 # INT32_MAX sentinel
		best_parent[i] = -1
		i += 1

	# Start from a deterministic node (0). If you want variety, randomize this later.
	var start: int = 0
	in_tree[start] = 1

	# Initialize costs from start
	i = 0
	while i < n:
		if i != start:
			best_cost[i] = _dist2(room_centers[start], room_centers[i])
			best_parent[i] = start
		i += 1

	var added: int = 1
	while added < n:
		var next_node: int = -1
		var next_cost: int = 2147483647

		# Find the cheapest node not yet in the tree
		i = 0
		while i < n:
			if in_tree[i] == 0 and best_cost[i] < next_cost:
				next_cost = best_cost[i]
				next_node = i
			i += 1

		# Shouldn't happen unless n is weird, but guard anyway.
		if next_node == -1:
			break

		in_tree[next_node] = 1
		added += 1

		var parent: int = best_parent[next_node]
		if parent >= 0:
			edges.append(RoomEdge.new(parent, next_node))

		# Relax edges from next_node to all non-tree nodes
		i = 0
		while i < n:
			if in_tree[i] == 0:
				var c: int = _dist2(room_centers[next_node], room_centers[i])
				if c < best_cost[i]:
					best_cost[i] = c
					best_parent[i] = next_node
			i += 1

	return edges

func _dist2(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (dx * dx) + (dy * dy)
