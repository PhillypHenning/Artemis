extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()

func _heal_to_full_after_time(parameters: Dictionary) -> void:
	var timers_group_node = parameters.timers_group_node
	
	if timers_group_node == null:
		push_error("Unable to find timers_group_node")
		return
		
	var timer = utils._get_timer_or_create(timers_group_node, parameters, _act_on_heal_to_full_after_time_timeout)
	if timer.is_stopped():
		timer.start()

func _act_on_heal_to_full_after_time_timeout(parameters: Dictionary) -> void:
	parameters.target.characteristics.current_health = clamp(parameters.target.characteristics.current_health + parameters.amount, 0, parameters.target.characteristics.max_health)
