class_name MovementAction
extends Action

var offset: Vector2i

func _init(directionX: int, directionY: int) -> void:
	offset = Vector2i(directionX, directionY)
