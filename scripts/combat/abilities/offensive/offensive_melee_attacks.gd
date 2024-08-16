extends Resource

func close_range_basic_attack(character: CombatCreatureBaseClass, amount: int) -> void:
	character._use_combat_creature_take_damage(amount)
