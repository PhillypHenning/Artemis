extends AI_Move_to_Action

var antsy_effect_value: int = 0
var radius: float = 100.0 
var speed: float = 1.0
var angle: float = 0.0

var circle_radius: float = 50.0 # Adjust this as needed for the desired circling distance

func _init() -> void:
	action_name = "CircularMoveToTarget"
	action_type = ACTION_TYPE.MOVE_TO
	# Assuming circling in the same vicinity as the DEADZONE
	preconditions = {}
	effects = {
		"current_antsy": {
			"apply": reduce_antsy,
			"validate": validate_antsy_effect,
		}
	}
	action_execution = {
		"do_action": {
			"direction": get_circular_direction,
			"distance": get_distance
		},
		"is_complete": is_complete
	}

func reduce_antsy(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character

func validate_antsy_effect(character: CombatCreatureBaseClass, target_value: float) -> bool:
	character = apply(character)
	return character.characteristics.current_antsy == target_value

func get_distance(_character: CombatCreatureBaseClass) -> float:
	return circle_radius

func get_circular_direction(character: CombatCreatureBaseClass) -> Vector2:
	var direction: Vector2
	var enemy_position: Vector2 = character.characteristics.enemy_target.position
	
	# Calculate the vector perpendicular to the direction to the enemy
	var to_enemy: Vector2 = enemy_position - character.global_position
	var perpendicular: Vector2 = Vector2(-to_enemy.y, to_enemy.x).normalized()
	
	# Determine movement direction (clockwise or counter-clockwise)
	if randf() < 0.5:
		perpendicular = -perpendicular  # Choose direction randomly for variation
	
	# Adjust current position slightly along the perpendicular
	var target_position: Vector2 = character.global_position + perpendicular * 0.1
	
	# Calculate new direction towards the adjusted position
	direction = character.global_position.direction_to(target_position)
	
	# Acts as a precision measure
	#if int(character.characteristics.distance_to_target) in range (distance-5, distance+5):
	if int(100) in range (distance-5, distance+5):
		direction = direction / 10
	
	return direction

func is_complete(character: CombatCreatureBaseClass) -> bool:
	return false
	return AIUtils.check_if_acceptable_distance(character.characteristics.distance_to_target, distance)
