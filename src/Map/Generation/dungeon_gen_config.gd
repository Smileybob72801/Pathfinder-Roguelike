class_name DungeonGenConfig

extends Resource

@export_category("Map")
@export var padding_from_border: int = 1

@export_category("Rooms")
@export var room_min_size: int = 6
@export var room_max_size: int = 10
@export var room_spacing: int = 1 # extra gap between rooms

@export_category("Components")
@export var room_placer: RoomPlacer
@export var room_connector: RoomConnector
@export var corridor_carver: CorridorCarver

@export_category("Tiles")
@export var floor_kind: MapData.TileKind = MapData.TileKind.FLOOR
@export var wall_kind: MapData.TileKind = MapData.TileKind.WALL
@export var floor_visual: MapData.TileVisual = MapData.TileVisual.FLOOR_FLAGSTONE
@export var wall_visual: MapData.TileVisual = MapData.TileVisual.WALL_STONE_BRICK
