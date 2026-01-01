class_name ChainRoomConnector

extends RoomConnector

func build_edges(rng: RandomNumberGenerator, room_centers: Array[Vector2i]) -> Array[RoomEdge]:
	var edges: Array[RoomEdge] = []
	if room_centers.size() < 2:
		return edges

	for i in range(1, room_centers.size()):
		edges.append(RoomEdge.new(i - 1, i))

	return edges
