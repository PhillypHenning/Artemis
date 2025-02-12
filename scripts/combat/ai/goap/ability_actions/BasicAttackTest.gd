extends AI_Use_Ability_Action

var offensive_melee_attacks = preload("res://scripts/combat/abilities/offensive/offensive_melee_attacks.gd").new()

func _init() -> void:
	action_name = "BasicAttackTest"
	action_type = ACTION_TYPE.USE_ABILITY
	preconditions = {
		"distance_to_target": determine_character_in_melee_close_range
	}
	effects = {
		"is_attacking": true
	}
	action_execution = {
		"do_action": {
			"ability": perform_attack
		},
		"is_complete": is_complete
	}
	ability = offensive_melee_attacks.close_range_basic_attack

# Preconditions:
#	Combat Creature can't already be attacking
#	Combat Creature should be in range to make the attack
# 	Combat Creature needs to have enough stamina to make the attack

# Effects:
# 	The Combat Creature will now be attacking
# 	The Combat Creature will use Stamina

func determine_character_in_melee_close_range(character: CombatCreatureBaseClass) -> bool:
	return AIUtils.check_if_target_in_range(character, character.characteristics.enemy_target.position, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE)

func is_complete(character: CombatCreatureBaseClass) -> bool:
	character.characteristics.is_attacking = false
	return true

func perform_attack(character: CombatCreatureBaseClass) -> void:
	ability.call(character.characteristics.enemy_target, 1)
