extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()

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

func _test_projectile(parameters: Dictionary) -> void:
	print("_test_projectile called")
	var spawned_bullet = parameters.bullet.instantiate()
	parameters.projectile_group_node.add_child(spawned_bullet)
	spawned_bullet.transform = parameters.shoot_at_position
	spawned_bullet.damage_amount = parameters.amount
	spawned_bullet.speed = parameters.speed
