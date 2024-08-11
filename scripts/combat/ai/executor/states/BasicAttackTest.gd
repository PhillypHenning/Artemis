extends AI_State

func _init():
	state_name = "BasicAttackTest"

func action(character: CombatCreatureBaseClass) -> void:
	print("Attack called")

func is_complete(character: CombatCreatureBaseClass) -> bool:
	for index in range(character.combat_creature_brain.available_actions.size()):
		if character.combat_creature_brain.available_actions[index].action_name == "BasicAttackTest":
			character.combat_creature_brain.available_actions.pop_at(index)
			break
	character.characteristics.is_attacking = false
	return true
