extends AI_Action

func _init() -> void:
	action_name = "MoveIntoDeadzone"
	preconditions = {
			#"distance_to_target": determine_character_in_deadzone
	}
	effects = {	# Effects
			"distance_to_target": {
				"callable": simulate_character_in_deadzone,
				"apply": false
			}
		}

func determine_character_in_deadzone(character: CombatCreatureBaseClass) -> bool:
	var distance = character.position.distance_to(character.characteristics.enemy_target.position)
	return !AIUtils.check_if_acceptable_distance(distance, CombatCreatureCharacteristics.PROXIMITY.DEADZONE)

func simulate_character_in_deadzone(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.distance_to_target = CombatCreatureCharacteristics.PROXIMITY.DEADZONE
	return character
