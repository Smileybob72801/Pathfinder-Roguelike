class_name EventHandler

extends Node

const MOVE_DELAY_MS := 50

var _last_move_time_ms: int = 0


func get_action() -> Action:
	var now_ms := Time.get_ticks_msec()

	if now_ms - _last_move_time_ms < MOVE_DELAY_MS:
		return null

	var action: Action = null
	var move_distance: int = 1

	if Input.is_action_pressed("ui_up"):
		action = MovementAction.new(0, -move_distance)
	elif Input.is_action_pressed("ui_down"):
		action = MovementAction.new(0, move_distance)
	elif Input.is_action_pressed("ui_left"):
		action = MovementAction.new(-move_distance, 0)
	elif Input.is_action_pressed("ui_right"):
		action = MovementAction.new(move_distance, 0)

	if action:
		_last_move_time_ms = now_ms
		return action

	if Input.is_action_just_pressed("ui_cancel"):
		return EscapeAction.new()

	return null
