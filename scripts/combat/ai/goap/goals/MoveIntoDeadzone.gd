extends AI_Goal

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

func _init(character: CombatCreatureBaseClass):
	self.goal_name = "MoveIntoDeadzone"
	self.goal_criteria = {
				"distance_to_target": { # Effect: distance_to_target = current_ideal_range
					"target_key": "current_ideal_range",
					"callable": func(a, b): return AIUtils.check_if_acceptable_distance(a, b)
				},
			}
	self.goal_priority = 2
	self.cc_character = character
