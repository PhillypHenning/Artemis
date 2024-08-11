extends Node

var character_node: CombatCreatureBaseClass
var current_state: AI_State
var state_index: int

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

var state_resources: Dictionary
var states_path: String = "res://scripts/combat/ai/executor/states"


func prep_ai_executor():
	# Loads all states
	# Improvement: Perhaps it would be better to have an externally managed state loader, at this will be called for every CombatCreature.
	state_resources = AIUtils.load_resources_to_dict(states_path, "gd")

# Execute action
func run_planner(current_plan: Array) -> Array:
	var actioned_plan = current_plan.duplicate()

	# Run through the current_plan
	for index in range(current_plan.size()):
		# Get state from action
		var target_state = state_resources.get(current_plan[index].action_name)

		if target_state:
			if !current_state:
				current_state = target_state # Set current_state to target_state
				state_index = index
				break
		else:
			push_error("State is undefined.. [{state}]".format({"state": current_plan[index].action_name}))

	if current_state:
		# Run the current_state action
		current_state.action(character_node)
		character_node = current_plan[state_index].apply(character_node, false)
		# Check that the state is complete
		if current_state.is_complete(character_node):
			current_state = null
			actioned_plan.pop_at(state_index)

	return actioned_plan
