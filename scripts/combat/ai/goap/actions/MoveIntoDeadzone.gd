extends AI_Action

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

func _init() -> void:
	action_name = "MoveIntoDeadzone"
	preconditions = {
			"distance_to_target": { # Precondition: distance_to_target != current_ideal_range
				"target_key": "current_ideal_range",
				"callable": func(a, b): return !AIUtils.check_if_acceptable_distance(a, b),
			},
		}
	effects = {	# Effects
			"distance_to_target": { # Effect: distance_to_target = current_ideal_range
				"target_key": "current_ideal_range",
				"callable": func(a): return float(a),
				"apply": false
			},
		}
