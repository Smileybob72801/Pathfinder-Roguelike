class_name MovementAction
extends Action

var offset: Vector2i

func _init(directionX: int, directionY: int) -> void:
	offset = Vector2i(directionX, directionY)

func perform(game: Game, entity: Entity) -> void:
	var destination: Vector2i = entity.grid_position + offset
	
	var map_data: MapData = game.get_map_data()
	
	if not map_data.can_enter_tile(destination):
		return
		
	entity.move(offset)
