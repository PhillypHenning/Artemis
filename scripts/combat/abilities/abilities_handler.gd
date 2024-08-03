class_name AbilityHandler
extends Node

var healing_abilities = preload("res://scripts/combat/abilities/healing_abilities.gd").new()
var movement_abilities = preload("res://scripts/combat/abilities/movement_abilities.gd").new()
var offensive_test_abilities = preload("res://scripts/combat/abilities/offensive/test_abilities.gd").new()

var test_bullet: PackedScene = preload("res://scenes/combat/projectiles/test_projectile.tscn")

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

enum OFFENSIVE_ABILITY_TYPES {
	TEST
}

enum OFFENSIVE_ABILITY_TEST_IDS {
	TESTING_CLOSE_MELEE,
	TESTING_MEDIUM_MELEE,
	TESTING_FAR_MELEE,
	TESTING_MULTI_PROXY_MELEE,
	TESTING_PROJECTILES
}

var ABILITIES = {
	HEALING: {
		HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME: {
			"target_callable": healing_abilities._heal_to_full_after_time,
			"parameters": {
				"target": null,
				"wait_time": 10,
				"one_shot": true,
				"amount": 0,
				"timer_name": "HealToFullAfterTime",
				"timers_group_node": null,
			},
		},
	},
	OFFENSIVE: {
		OFFENSIVE_ABILITY_TYPES.TEST: {
			OFFENSIVE_ABILITY_TEST_IDS.TESTING_CLOSE_MELEE: {
				"target_callable": offensive_test_abilities._close_melee_attack,
				"parameters": {
					"target_location": null,
					"amount": 0,
					"proximity_needed": [CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE],
				}
			},
			OFFENSIVE_ABILITY_TEST_IDS.TESTING_MEDIUM_MELEE: {
				"target_callable": offensive_test_abilities._medium_melee_attack,
				"parameters": {
					"target_location": null,
					"amount": 0,
					"proximity_needed": [CombatCreatureCharacteristics.PROXIMITY.MELEE_MEDIUM],
				}
			},
			OFFENSIVE_ABILITY_TEST_IDS.TESTING_FAR_MELEE: {
				"target_callable": offensive_test_abilities._far_melee_attack,
				"parameters": {
					"target_location": null,
					"amount": 0,
					"proximity_needed": [CombatCreatureCharacteristics.PROXIMITY.MELEE_FAR],
				}
			},
			OFFENSIVE_ABILITY_TEST_IDS.TESTING_MULTI_PROXY_MELEE: {
				"target_callable": offensive_test_abilities._multi_proxy_melee_attack,
				"parameters": {
					"target_location": null,
					"amount": 0,
					"proximity_needed": [CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE, CombatCreatureCharacteristics.PROXIMITY.MELEE_MEDIUM],
				}
			},
			OFFENSIVE_ABILITY_TEST_IDS.TESTING_PROJECTILES: {
				"target_callable": offensive_test_abilities._test_projectile,
				"parameters": {
					"shoot_at_position": null,
					"amount": 0,
					"bullet": test_bullet,
					"projectile_group_node": projectile_group_node,
					"speed": 750,
				}
			},
		}
	},
	DEFENSIVE: {},
	UTILITY: {},
	MOVEMENT: {
		MOVEMENT_ABILITY_IDS.TESTING_DODGE :{
			"target_callable": movement_abilities._use_dodge,
			"parameters": {
				"target": null,
				"wait_time": .5,
				"one_shot": true,
				"timer_name": "MovementAbilityTimer",
				"timers_group_node": null,
			},
		},
		MOVEMENT_ABILITY_IDS.TESTING_DASH :{
			"target_callable": movement_abilities._use_dash,
			"parameters": {
				"target": null,
				"wait_time": .25,
				"one_shot": true,
				"timer_name": "MovementAbilityTimer",
				"timers_group_node": null,
			},
		},
	},
}

var timers_group_node: Node
var projectile_group_node: Node

func _init_ability_handler(parent_node: Node) -> void:
	timers_group_node = Node.new()
	timers_group_node.name = "AbilityTimers"
	parent_node.add_child(timers_group_node)
	
	projectile_group_node = Node.new()
	projectile_group_node.name = "Projectiles"
	parent_node.add_child(projectile_group_node)

func _use_ability(target_ability: Dictionary, parameters: Dictionary):
	var keys = target_ability.parameters.keys()
	if "projectile_group_node" in keys:
		parameters.projectile_group_node = projectile_group_node
	if "timers_group_node" in keys:
		parameters.timers_group_node = timers_group_node

	target_ability.parameters.merge(parameters, true) 				# Merge default parameters with supplied parameters
	target_ability.target_callable.call(target_ability.parameters)	# Invoke callable
