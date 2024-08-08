extends Node

var character_node: CombatCreatureBaseClass
var current_state: AI_State

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

var State: Dictionary
var states_path: String = "res://scripts/combat/ai/executor/states"

func prep_ai_executor():
	# Loads all states
	# Improvement: Perhaps it would be better to have an externally managed state loader, at this will be called for every CombatCreature.
	for file_name in DirAccess.get_files_at(states_path):
		if (file_name.get_extension() == "tres"):
			var state = file_name.replace('.tres', '').replace("State", '')
			State.merge({state: ResourceLoader.load(states_path+"/"+file_name)})

# Execute action
func run_planner(current_plan: Array) -> Array:
	var actioned_plan = current_plan.duplicate()	
	var last_index: int
	# Run through the current_plan
	for index in range(current_plan.size()):
		last_index = index
		# Get state from action
		var target_state = State.get(current_plan[index].action_name)
		
		if target_state:
			if !current_state:
				current_state = target_state # Set current_state to target_state
				break
		else:
			push_error("State is undefined.. [{state}]".format({"state": current_plan[index].action_name}))

	if current_state:
		# Run the current_state action
		current_state.action(character_node)
		character_node.characteristics = current_plan[last_index].apply(character_node.characteristics, false)
		# Check that the state is complete
		if current_state.is_complete(character_node):
			current_state = null
			actioned_plan.pop_at(last_index)
	
	return actioned_plan
