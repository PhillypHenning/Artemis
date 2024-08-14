extends AI_Move_to_Action

var antsy_effect_value: int = 10
var radius: float = 100.0 
var speed: float = 1.0
var angle: float = 0.0

func _init() -> void:
	action_name = "CircleEnemy"
	action_type = ACTION_TYPE.MOVE_TO
	preconditions = {}
	effects = {
		"current_antsy": {
			"apply": apply_effect,
			"validate": validate_effect,
		}
	}
	action_execution = {
		"do_action": {
			"direction": get_direction,
			"distance": get_distance
		},
		"is_complete": is_complete
	}

func apply_effect(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character

func validate_effect(character: CombatCreatureBaseClass, target_value: float) -> bool:
	character = apply(character)
	return character.characteristics.current_antsy == target_value

func get_distance(_character: CombatCreatureBaseClass) -> float:
	return 1

func get_direction(_character: CombatCreatureBaseClass) -> Vector2:
	var lor = randi_range(0, 1)
	# if -0 circle left, if 1 circle right
	
	
	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var new_position = Vector2(rand_x, rand_y)
	return new_position

func is_complete(_character: CombatCreatureBaseClass) -> bool:
	return true
