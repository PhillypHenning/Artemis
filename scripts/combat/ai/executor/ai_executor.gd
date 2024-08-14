extends Node

var character_node: CombatCreatureBaseClass
var current_state: AI_State
var state_index: int

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

var state_resources: Dictionary
var states_path: String = "res://scripts/combat/ai/executor/states"
var execution_limit = 200
var execution_counter = 0

func prep_ai_executor():
	# Loads all states
	# Improvement: Perhaps it would be better to have an externally managed state loader, at this will be called for every CombatCreature.
	state_resources = AIUtils.load_resources_to_dict(states_path, "gd")

# Execute action
func run_planner(current_plan: Array) -> Array:
	execution_counter+=1
	var actioned_plan = current_plan.duplicate()

	# Run through the current_plan
	for index in range(current_plan.size()):
		# Get state from action
		if !current_state:
			var target_state: Resource
			match current_plan[index].action_type:
				AI_Action.ACTION_TYPE.MOVE_TO:
					target_state = state_resources.get("MoveTo").duplicate(true)
					target_state.target_action_properties = current_plan[index].action_execution.do_action
					target_state.target_is_complete = current_plan[index].action_execution.is_complete
					target_state.calculate_target_location(character_node)
					var timer = current_plan[index].action_execution.do_action.get("action_timer")
					if timer:
						timer.call(character_node)
					var update = current_plan[index].action_execution.do_action.get("update")
					if update:
						target_state.update = update


				AI_Action.ACTION_TYPE.USE_ABILITY:
					target_state = state_resources.get("UseAbility").duplicate(true)
					target_state.ability_name = current_plan[index].action_name
					target_state.target_action_properties = current_plan[index].action_execution.do_action
					target_state.target_is_complete = current_plan[index].action_execution.is_complete
			
			if target_state:
				current_state = target_state # Set current_state to target_state
				state_index = index
				break
	if current_state:
		# Run the current_state action
		current_state.action(character_node)
		character_node = current_plan[state_index].apply(character_node, false)
		# Check that the state is complete
		if current_state.is_complete(character_node):
			current_state = null
			actioned_plan.pop_at(state_index)
	
	if actioned_plan.size() == 0:
		execution_counter=0
	
	if execution_counter == execution_limit:
		actioned_plan = []
		execution_counter=0
	
	return actioned_plan
