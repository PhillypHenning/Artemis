extends AI_Action

func _init() -> void:
	action_name = "MoveIntoDeadzone"
	preconditions = {}
	effects = {
			"distance_to_target": {
				"apply": simulate_character_in_deadzone,
				"validate": determine_character_in_deadzone,
				"simulate_only": true
			}
		}

func determine_character_in_deadzone(character: CombatCreatureBaseClass, criteria: Callable) -> bool:
	simulate_character_in_deadzone(character)
	return AIUtils.check_if_acceptable_distance(character.characteristics.distance_to_target, CombatCreatureCharacteristics.PROXIMITY.DEADZONE)

func simulate_character_in_deadzone(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.distance_to_target = CombatCreatureCharacteristics.PROXIMITY.DEADZONE
	return character
