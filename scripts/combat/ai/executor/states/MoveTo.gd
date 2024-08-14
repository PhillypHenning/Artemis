extends AI_State

var target_location: Vector2

func action(character: CombatCreatureBaseClass):
	if update:
		update.call(character)
	character.handle_combat_creature_basic_movement(target_location)

func is_complete(character: CombatCreatureBaseClass) -> bool:
	return target_is_complete.call(character, target_location)

func calculate_target_location(character: CombatCreatureBaseClass) -> void:
	var direction = target_action_properties.get("direction").call(character)
	var distance = target_action_properties.get("distance").call(character)
	var displacement = direction * distance
	target_location = character.position + displacement
