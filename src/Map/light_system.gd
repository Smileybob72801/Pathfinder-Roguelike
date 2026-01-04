class_name LightSystem

extends RefCounted

var _fov := FieldOfView.new()

func rebuild_illumination(
	map_data: MapData,
	illum: IlluminationMap,
	lights: Array[LightSource]
) -> void:
	illum.fill(LightLevel.DARKNESS)

	for light in lights:
		var tmp_vision := VisionState.new(illum.width, illum.height, false)
		var cells := _fov.compute(map_data, tmp_vision, light.position, light.dim_radius)

		for cell in cells:
			var d := Grid.distance_pf(light.position, cell)

			# Bright vs Normal: PF torch is normal, not “bright”.
			# Keep Bright reserved for daylight / special sources.
			if d <= light.normal_radius:
				illum.set_level_max(cell, LightLevel.NORMAL)
			elif d <= light.dim_radius:
				illum.set_level_max(cell, LightLevel.DIM)
