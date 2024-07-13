extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()

func _use_dash(parameters: Dictionary) -> void:
	var timers_group_node = parameters.timers_group_node
	
	if timers_group_node == null:
		push_error("Unable to find timers_group_node")
		return
	
	if !parameters.target.combat_creature_movement_characteristics.is_using_movement_ability:
		parameters.target.combat_creature_movement_characteristics.is_using_movement_ability = true
		parameters.target.combat_creature_nodes[parameters.target.MOVEMENT].movement_override = _movement_override_dash
		var timer = utils._get_timer_or_create(timers_group_node, parameters, _finish_dash)
		timer.start()

func _movement_override_dash(parameters) -> void:
	parameters.target.velocity = parameters.target.combat_creature_nodes[parameters.target.POSITIONS].last_known_direction * (parameters.target.combat_creature_movement_characteristics.current_speed * 5)
	parameters.target.move_and_slide()

func _finish_dash(parameters: Dictionary) -> void:
	parameters.target.combat_creature_movement_characteristics.is_using_movement_ability = false
	parameters.target.combat_creature_nodes[parameters.target.MOVEMENT].movement_override = null


func _use_dodge(parameters: Dictionary) -> void:
	var timers_group_node = parameters.timers_group_node
	
	if timers_group_node == null:
		push_error("Unable to find timers_group_node")
		return
	
	if !parameters.target.combat_creature_movement_characteristics.is_using_movement_ability:
		parameters.target.combat_creature_movement_characteristics.is_using_movement_ability = true
		parameters.target.combat_creature_nodes[parameters.target.MOVEMENT].movement_override = _movement_override_dodge
		var timer = utils._get_timer_or_create(timers_group_node, parameters, _finish_dodge)
		timer.start()

func _movement_override_dodge(_parameters) -> void:
	pass

func _finish_dodge(parameters: Dictionary) -> void:
	parameters.target.combat_creature_movement_characteristics.is_using_movement_ability = false
	parameters.target.combat_creature_nodes[parameters.target.MOVEMENT].movement_override = null
