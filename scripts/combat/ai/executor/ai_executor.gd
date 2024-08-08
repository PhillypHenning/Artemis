extends Node

var character_node: CombatCreatureBaseClass
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

# Execute action
func run_planner() -> Array:
	var current_plan = character_node.current_plan
	var actioned_plan = current_plan.duplicate()

	for action in current_plan:
		match action.action_name:
			"DoTheAntsyShuffle":
				print("DoTheAntsyShuffle called")
				if do_the_antsy_shuffle():
					character_node.characteristics = action.apply(character_node.characteristics)
					actioned_plan.pop_front()
			"MoveIntoIdealRange":
				print("DoTheAntsyShuffle called")
				if do_move_into_ideal_range():
					character_node.characteristics = action.apply(character_node.characteristics)
					actioned_plan.pop_front()
			"CircleEnemy":
				print("CircleEnemy called")
				actioned_plan.pop_front()
	return actioned_plan


func do_the_antsy_shuffle() -> bool:
	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var new_position = Vector2(rand_x, rand_y)
	character_node._handle_combat_creature_basic_movement(new_position)
	return true

func do_move_into_ideal_range() -> bool:
	var direction: Vector2	
	if !AIUtils.check_if_acceptable_distance(character_node.characteristics.distance_to_target, character_node.characteristics.current_ideal_range):
		if round(character_node.characteristics.distance_to_target) > round(character_node.characteristics.current_ideal_range):
			direction = character_node.global_position.direction_to(character_node.characteristics.enemy_target.position)
		elif round(character_node.characteristics.distance_to_target) < round(character_node.characteristics.current_ideal_range):
			direction = character_node.global_position.direction_to(character_node.characteristics.enemy_target.position) * -1
		character_node._handle_combat_creature_basic_movement(direction)
		return false
	return true
