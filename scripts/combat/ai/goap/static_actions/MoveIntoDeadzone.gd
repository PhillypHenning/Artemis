extends AI_Move_to_Action

func _init() -> void:
	action_name = "MoveIntoDeadzone"
	action_type = ACTION_TYPE.MOVE_TO
	distance = CombatCreatureCharacteristics.PROXIMITY.DEADZONE
	preconditions = {}
	effects = {
			"distance_to_target": {
				"apply": simulate_character_in_deadzone,
				"validate": determine_character_in_deadzone,
				"simulate_only": true
			}
		}
	action_execution = {
		"do_action": {
			"direction": get_direction,
			"distance": get_distance
		},
		"is_complete": is_complete
	}

func determine_character_in_deadzone(character: CombatCreatureBaseClass, criteria: Callable) -> bool:
	simulate_character_in_deadzone(character)
	return criteria.call(character)

func simulate_character_in_deadzone(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.distance_to_target = distance
	return character

func get_distance(_character: CombatCreatureBaseClass) -> float:
	return distance

func get_direction(character: CombatCreatureBaseClass) -> Vector2:
	var direction: Vector2
	if round(character.characteristics.distance_to_target) > distance:
		direction = character.global_position.direction_to(character.characteristics.enemy_target.position)
	elif round(character.characteristics.distance_to_target) < distance:
		direction = character.global_position.direction_to(character.characteristics.enemy_target.position) * -1
	
	# Acts as a precision measure
	if int(character.characteristics.distance_to_target) in range (distance-5, distance+5):
		direction = direction / 10
	return direction

func is_complete(character: CombatCreatureBaseClass) -> bool:
	return AIUtils.check_if_acceptable_distance(character.characteristics.distance_to_target, distance)
