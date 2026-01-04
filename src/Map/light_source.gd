class_name LightSource

extends RefCounted

var position: Vector2i
var normal_radius: int
var dim_radius: int

func _init(pos: Vector2i, normal_radius: int, dim_radius: int) -> void:
	position = pos
	self.normal_radius = normal_radius
	self.dim_radius = dim_radius
