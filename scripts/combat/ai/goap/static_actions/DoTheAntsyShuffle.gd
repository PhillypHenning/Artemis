extends AI_Action

var antsy_effect_value: int = 10

func _init() -> void:
	action_name = "DoTheAntsyShuffle"
	preconditions = {}
	effects = {
		"current_antsy": {
			"apply": antsy_apply,
			"validate": antsy_validate,
		}
	}

func antsy_apply(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character

func antsy_validate(character: CombatCreatureBaseClass, target_value: float) -> bool:
	antsy_apply(character)
	return character.characteristics.current_antsy == target_value
