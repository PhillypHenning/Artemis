extends AI_State

func action(character: CombatCreatureBaseClass):
	var direction = target_action_properties.get("direction").call(character)
	#var distance = target_action_properties.get("distance").call(character)
	character._handle_combat_creature_basic_movement(direction)

func is_complete(character: CombatCreatureBaseClass) -> bool:
	return target_is_complete.call(character)

