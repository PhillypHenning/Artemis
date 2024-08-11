extends AI_Action

func _init() -> void:
	action_name = "MoveIntoMeleeCloseRange"
	preconditions = {}
	effects = {
			"distance_to_target": {
				"apply": simulate_character_in_melee_close_range,
				"validate": determine_character_in_melee_close_range,
				"simulate_only": true
			}
		}

func determine_character_in_melee_close_range(character: CombatCreatureBaseClass, criteria: Callable) -> bool:
	simulate_character_in_melee_close_range(character)
	return AIUtils.check_if_acceptable_distance(character.characteristics.distance_to_target, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE)

func simulate_character_in_melee_close_range(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.distance_to_target = CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE
	return character
