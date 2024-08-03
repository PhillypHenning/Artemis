extends Node

var character_node: CombatCreatureBaseClass

# Execute action
func run_planner() -> Array:
	var current_plan = character_node.current_plan
	var actioned_plan = current_plan.duplicate()
	
	for action in current_plan:
		match action.action_name:
			"DoTheAntsyShuffle":
				if do_the_antsy_shuffle():
					pass
					actioned_plan.pop_front()
		character_node.characteristics = action.apply(character_node.characteristics)
	return actioned_plan


func do_the_antsy_shuffle() -> bool:
	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var new_position = Vector2(rand_x, rand_y)
	character_node._handle_combat_creature_basic_movement(new_position)
	return true

