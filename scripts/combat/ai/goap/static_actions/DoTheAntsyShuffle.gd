extends AI_Move_to_Action

var antsy_effect_value: int = 10

func _init() -> void:
	action_name = "DoTheAntsyShuffle"
	action_type = ACTION_TYPE.MOVE_TO
	preconditions = {}
	effects = {
		"current_antsy": {
			"apply": antsy_apply,
			"validate": antsy_validate,
		}
	}
	action_execution = {
		"do_action": {
			"direction": get_direction,
			"distance": get_distance
		},
		"is_complete": is_complete
	}

func antsy_apply(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character

func antsy_validate(character: CombatCreatureBaseClass, target_value: float) -> bool:
	antsy_apply(character)
	return character.characteristics.current_antsy == target_value

func get_distance(character: CombatCreatureBaseClass) -> float:
	return 1

func get_direction(character: CombatCreatureBaseClass) -> Vector2:
	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var new_position = Vector2(rand_x, rand_y)
	return new_position

func is_complete(character: CombatCreatureBaseClass) -> bool:
	return true
