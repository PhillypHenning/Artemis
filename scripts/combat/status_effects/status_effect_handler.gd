extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()

enum {
	DAMAGE_IMMUNITY
}

var status_effects = {
	DAMAGE_IMMUNITY: {
		"parameters": {
			"target": null,
		},
		"on_start": {
			"target_callable": _apply_damage_immunity
		},
		"on_interm": {},
		"on_finish": {
			"wait_time": 0.1,
			"one_shot": true,
			"timer_name": "DamageImmunityEndTimer",
			"target_callable": _finish_damage_immunity
		},
	}
}

var timers_group_node: Node


func _init_ability_handler(parent_node: Node) -> void:
	timers_group_node = Node.new()
	timers_group_node.name = "StatusEffectTimers"
	parent_node.add_child(timers_group_node)
	
func _start_status_effect(target_ability, parameters):
	target_ability.parameters.merge(parameters, true) 				# Merge default parameters with supplied parameters
	target_ability.on_start.target_callable.call(target_ability.parameters)	# Invoke callable



func _apply_damage_immunity(parameters: Dictionary) -> void:
	print("_apply_damage_immunity called")
	
	if timers_group_node == null:
		push_error("Unable to find timers_group_node")
		return
	
	parameters.target.characteristics.can_take_damage = false
	
	var finish_parameters = parameters.duplicate()
	finish_parameters.merge(status_effects[DAMAGE_IMMUNITY].on_finish)
	
	var timer = utils._get_timer_or_create(timers_group_node, finish_parameters, _finish_damage_immunity)
	if timer.is_stopped():
		timer.start()

func _finish_damage_immunity(parameters: Dictionary) -> void:
	print("_finish_damage_immunity called")
	parameters.target.characteristics.can_take_damage = true
