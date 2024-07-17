extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()
var proximities = preload("res://scripts/combat/statics/proximity.gd").new()

func _close_melee_attack(parameters: Dictionary) -> void:
	if parameters.target.combat_creature_nodes[parameters.target.TARGETTING][parameters.target.TARGETTING_DETAILS.PROXIMITY].proximity_range in parameters.proximity_needed:
		parameters.target._use_combat_creature_take_damage(parameters.amount)
	else:
		print("Attack out of range")

func _medium_melee_attack(parameters: Dictionary) -> void:
	if parameters.target.combat_creature_nodes[parameters.target.TARGETTING][parameters.target.TARGETTING_DETAILS.PROXIMITY].proximity_range in parameters.proximity_needed:
		parameters.target._use_combat_creature_take_damage(parameters.amount)
	else:
		print("Attack out of range")
		
func _far_melee_attack(parameters: Dictionary) -> void:
	if parameters.target.combat_creature_nodes[parameters.target.TARGETTING][parameters.target.TARGETTING_DETAILS.PROXIMITY].proximity_range in parameters.proximity_needed:
		parameters.target._use_combat_creature_take_damage(parameters.amount)
	else:
		print("Attack out of range")


func _multi_proxy_melee_attack(parameters: Dictionary) -> void:
	if parameters.target.combat_creature_nodes[parameters.target.TARGETTING][parameters.target.TARGETTING_DETAILS.PROXIMITY].proximity_range in parameters.proximity_needed:
		parameters.target._use_combat_creature_take_damage(parameters.amount)
	else:
		print("Attack out of range")
