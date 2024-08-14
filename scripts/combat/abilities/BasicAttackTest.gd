class_name ABILITY_TESTING
extends Resource

func perform_basic_attack_test(character: CombatCreatureBaseClass, damage: int) -> void:
	character.characteristics.enemy_target._use_combat_creature_take_damage(damage)
