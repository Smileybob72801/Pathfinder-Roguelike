class_name EventHandler

extends Node

func get_action() -> Action:
	var action: Action = null
	
	var moveDistance: int = 1
	
	if Input.is_action_just_pressed("ui_up"):
		action = MovementAction.new(0, -(moveDistance))
	elif Input.is_action_just_pressed("ui_down"):
		action = MovementAction.new(0, moveDistance)
	elif Input.is_action_just_pressed("ui_left"):
		action = MovementAction.new(-(moveDistance), 0)
	elif Input.is_action_just_pressed("ui_right"):
		action = MovementAction.new(moveDistance, 0)
		
	if Input.is_action_just_pressed("ui_cancel"):
		action = EscapeAction.new()
		
	return action
