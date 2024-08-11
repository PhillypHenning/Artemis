extends AI_Action

var antsy_effect_value: int = 10

func _init() -> void:
	action_name = "DoTheAntsyShuffle"
	preconditions = {
		"current_antsy": func(character): return character.characteristics.current_antsy > .9,
	}
	effects = {
		"current_antsy": float(-10)
	}

func simulate_character(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character
