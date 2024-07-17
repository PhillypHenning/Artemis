extends Node

var utils = preload("res://scripts/combat/utils/utils.gd").new()

func _close_melee_attack(parameters: Dictionary) -> void:
	print("_close_melee_attack called")
	parameters.target._use_combat_creature_take_damage(parameters.amount)
