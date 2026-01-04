class_name Game

extends Node2D

const player_definition: EntityDefinition = preload("res://assets/definitions/entities/actors/entity_definition_player.tres")

@onready var player: Entity
@onready var event_handler: EventHandler = $EventHandler
@onready var entities: Node2D = $Entities
@onready var map: Map = $Map

var _fov: FieldOfView = FieldOfView.new()
var _light_system := LightSystem.new()
var _illumination: IlluminationMap

# Debug tools
var _torch_spawner: TorchSpawner = TorchSpawner.new()

func _ready() -> void:
	var player_start_pos: Vector2i = map.get_player_spawn()
	player = Entity.new(player_start_pos, player_definition)
	entities.add_child(player)
	
	# Player gets explored memory
	# TODO: enemies can get visible-only later.
	player.vision_state = VisionState.new(map.map_data.width, map.map_data.height, true)
	
	var camera: Camera2D = $Camera2D
	remove_child(camera)
	player.add_child(camera)
	
	var npc := Entity.new(player_start_pos + Vector2i.RIGHT, player_definition)
	npc.modulate = Color.ORANGE_RED
	entities.add_child(npc)
	
	_illumination = IlluminationMap.new(map.map_data.width, map.map_data.height, LightLevel.DARKNESS)
	_update_player_vision_and_light()
	
func get_map_data() -> MapData:
	return map.map_data

func _physics_process(_delta: float) -> void:
	var action: Action = event_handler.get_action()
	if action:
		var before := player.grid_position
		action.perform(self, player)
		
		if player.grid_position != before:
			_update_player_vision_and_light()


func _update_player_vision_and_light() -> void:
	
	# Example radii: torch normal 4, dim 8
	var normal_radius := 4
	var dim_radius := 8

	var lights: Array[LightSource] = []

	# Player torch
	lights.append(LightSource.new(player.grid_position, normal_radius, dim_radius))

	# Add all spawned test torches:
	lights.append_array(_torch_spawner.build_light_sources(normal_radius, dim_radius))

	_light_system.rebuild_illumination(map.map_data, _illumination, lights)
	var max_los := 50

	# LoS candidates
	var los_cells := _fov.compute_cells(map.map_data, player.grid_position, max_los)
	
	player.vision_state.clear_visible()
	
	var visible_cells: Array[Vector2i] = []
	
	# Interpret illumination for a normal-vision human:
	# Visible if illumination is at least DIM.
	# TODO: Handle darkvision, low light, blindsense, etc..
	for cell in los_cells:
		var lvl := _illumination.get_level(cell)

		if lvl >= LightLevel.DIM:
			player.vision_state.set_visible(cell, true)
			player.vision_state.set_perceived_light(cell, lvl)
			visible_cells.append(cell)

	# Rendering uses explored + visible + perceived_light
	map.apply_player_vision(player.vision_state, visible_cells)


func spawn_test_torch(cell: Vector2i) -> void:
	# Optional safety checks (recommended)
	if not map.map_data.is_in_bounds(cell):
		return
	if map.map_data.get_kind(cell) == MapData.TileKind.WALL:
		return

	_torch_spawner.add_torch(cell)
	_update_player_vision_and_light()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			var cell := Grid.world_to_grid(get_global_mouse_position())
			spawn_test_torch(cell)
