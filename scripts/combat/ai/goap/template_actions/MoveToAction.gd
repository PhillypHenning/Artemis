class_name AI_Move_to_Action
extends AI_Action

var distance: float

func _init() -> void:
	action_type = ACTION_TYPE.MOVE_TO
	effects = {
		"distance_to_target": {
			"apply": simulate_character_target_location,
			"validate": determine_character_in_target_location,
			"simulate_only": true
		}
	}
	action_execution = {
		"do_action": {
			"direction": get_direction,
			"distance": get_distance
		},
		"is_complete": character_at_target_location
	}

func determine_character_in_target_location(character: CombatCreatureBaseClass, criteria: Callable) -> bool:
	simulate_character_target_location(character)
	return criteria.call(character)

func simulate_character_target_location(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	var target_direction = get_direction(character)
	var target_distance = get_distance(character)
	var displacement = target_direction * target_distance
	character.position = character.position + displacement
	return character

func get_distance(character: CombatCreatureBaseClass) -> float:
	var target_distance = character.position.distance_to(character.characteristics.enemy_target.position) - distance
	return target_distance

func get_direction(character: CombatCreatureBaseClass) -> Vector2:
	return character.position.direction_to(character.characteristics.enemy_target.position)

func character_at_target_location(character: CombatCreatureBaseClass, _target_location: Vector2) -> bool:
	return AIUtils.check_if_target_in_range(character, character.characteristics.enemy_target.position, distance)
