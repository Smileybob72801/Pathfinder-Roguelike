class_name CorridorWidthDistribution

extends Resource

@export var options: Array[WeightedInt] = []

func pick(rng: RandomNumberGenerator) -> int:
	if options.is_empty():
		return 1

	var total: float = 0.0
	for o in options:
		if o == null:
			continue
		if o.weight > 0.0:
			total += o.weight

	if total <= 0.0:
		return maxi(1, options[0].value)

	var roll: float = rng.randf() * total
	var acc: float = 0.0

	for o in options:
		if o == null:
			continue
		if o.weight <= 0.0:
			continue

		acc += o.weight
		if roll <= acc:
			return maxi(1, o.value)

	return maxi(1, options.back().value)
