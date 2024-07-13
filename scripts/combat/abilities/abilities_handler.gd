class_name AbilityHandler
extends Node

var healing_abilities = preload("res://scripts/combat/abilities/healing_abilities.gd").new()
var movement_abilities = preload("res://scripts/combat/abilities/movement_abilities.gd").new()

enum {
	HEALING,
	OFFENSIVE,
	DEFENSIVE,
	UTILITY,
	MOVEMENT
}

enum HEALING_ABILITY_IDS {
	HEAL_TO_FULL_AFTER_TIME
}

enum MOVEMENT_ABILITY_IDS {
	TESTING_DODGE,
	TESTING_DASH
}

var ABILITIES = {
	HEALING: {
		HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME: {
			"name": "Example Card: Heal To Full After Time",
			"target_callable": healing_abilities._heal_to_full_after_time,
			"parameters": {
				"target": null,
				"wait_time": 0,
				"one_shot": true,
				"amount": 0
			},
			"timer_name": "HealToFullAfterTime",
		},
	},
	OFFENSIVE: {},
	DEFENSIVE: {},
	UTILITY: {},
	MOVEMENT: {
		MOVEMENT_ABILITY_IDS.TESTING_DODGE :{
			"name": "Testing Dodge",
			"target_callable": movement_abilities._use_dodge,
			"parameters": {
				"target": null,
				"wait_time": .5,
				"one_shot": true,
				"timer_name": "MovementAbilityTimer"
			},
		},
		MOVEMENT_ABILITY_IDS.TESTING_DASH :{
			"name": "Testing Dash",
			"target_callable": movement_abilities._use_dash,
			"parameters": {
				"target": null,
				"wait_time": .25,
				"one_shot": true,
				"timer_name": "MovementAbilityTimer"
			},
		},
	},
}

var timers_group_node: Node


func _init_ability_handler(parent_node: Node) -> void:
	timers_group_node = Node.new()
	timers_group_node.name = "AbilityTimers"
	parent_node.add_child(timers_group_node)

func _use_ability(target_ability, parameters):
	target_ability.parameters.timers_group_node = timers_group_node
	target_ability.parameters.merge(parameters, true) 				# Merge default parameters with supplied parameters
	target_ability.target_callable.call(target_ability.parameters)	# Invoke callable

