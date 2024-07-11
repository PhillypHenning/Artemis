class_name AbilityHandler
extends Node

var healing_abilities = preload("res://scripts/combat/abilities/healing_abilities.gd").new()

enum ABILITIES_IDS {
	HEALING,
	OFFENSIVE,
	DEFENSIVE,
	UTILITY
}

enum HEALING_ABILITY_IDS {
	HEAL_TO_FULL_AFTER_TIME
}

var ABILITIES = {
	ABILITIES_IDS.HEALING: {
		HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME: {
			"name": "Example Card: Heal To Full After Time",
			"target_callable": healing_abilities._heal_to_full_after_time,
			"parameters_overrides": {
				"target": null,
				"wait_time": 0,
				"one_shot": true,
				"amount": 0
			},
			"timer_name": "HealToFullAfterTime",
		},
	},
	ABILITIES_IDS.OFFENSIVE: {},
	ABILITIES_IDS.DEFENSIVE: {},
	ABILITIES_IDS.UTILITY: {},
}


func _init_ability_handler(parent_node: Node) -> void:	
	# Create Timers Group
	var healing_abilities_timers_node_group = Node.new()
	healing_abilities_timers_node_group.name = "AbilityTimers"
	parent_node.add_child(healing_abilities_timers_node_group)
