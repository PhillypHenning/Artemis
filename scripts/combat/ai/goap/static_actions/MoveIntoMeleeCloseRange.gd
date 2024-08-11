extends AI_Action

func _init() -> void:
	action_name = "MoveIntoMeleeCloseRange"
	preconditions = {
			#"distance_to_target": determine_if_character_is_outside_melee_close_range
		}
	effects = {	# Effects
			"distance_to_target": {
				"callable": simulate_character_in_melee_close_range,
				"apply": false
			}
		}

func determine_if_character_is_outside_melee_close_range(character: CombatCreatureBaseClass) -> bool:
	var distance = character.position.distance_to(character.characteristics.enemy_target.position)
	return !AIUtils.check_if_acceptable_distance(distance, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE)

func simulate_character_in_melee_close_range(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.distance_to_target = CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE
	return character
