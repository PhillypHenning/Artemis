extends AI_State

var ability_name: String

func action(character: CombatCreatureBaseClass) -> void:
	target_action_properties["ability"].call(character)

func is_complete(character: CombatCreatureBaseClass) -> bool:
	for index in range(character.combat_creature_brain.available_actions.size()):
		if character.combat_creature_brain.available_actions[index].action_name == ability_name:
			character.combat_creature_brain.available_actions.pop_at(index)
			break
	return target_is_complete.call(character)
