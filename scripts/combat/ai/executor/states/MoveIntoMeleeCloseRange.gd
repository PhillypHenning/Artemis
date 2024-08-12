extends AI_State

func _init():
	state_name = "MoveIntoMeleeCloseRange"

func action(character_node: CombatCreatureBaseClass):
	var direction: Vector2	
	if round(character_node.characteristics.distance_to_target) > CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE:
		direction = character_node.global_position.direction_to(character_node.characteristics.enemy_target.position)
	elif round(character_node.characteristics.distance_to_target) < CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE:
		direction = character_node.global_position.direction_to(character_node.characteristics.enemy_target.position) * -1
	
	# Acts as a precision measure
	if int(character_node.characteristics.distance_to_target) in range (CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE-5, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE+5):
		direction = direction / 10
	
	character_node._handle_combat_creature_basic_movement(direction)

func is_complete(character_node: CombatCreatureBaseClass) -> bool:
	return AIUtils.check_if_acceptable_distance(character_node.characteristics.distance_to_target, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE)
