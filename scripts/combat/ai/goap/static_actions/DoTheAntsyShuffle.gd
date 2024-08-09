extends AI_Action

func _init() -> void:
	action_name = "DoTheAntsyShuffle"
	preconditions = {
		"current_antsy": func(character): return character.characteristics.current_antsy > .9,
	}
	effects = {
		"current_antsy": float(-10),
	}
