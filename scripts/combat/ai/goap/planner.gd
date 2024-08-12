extends Node
class_name Planner



# build_plan
# 	1. Combines available_actions and static_actions
#	2. Sorts the primary_goals according to their goal_priority
#	3. Creates an empty plan array
#	4. Cycles through each goal in primary_goals
#		a. Attempts to build a plan (an array of actions to take to meet a goal)
#		b. If the plan is returned empty, then it moves on to the next goal
#		c. If the plan isn't empty it returns the plan (Array of actions)
#	5. Return the empty plan
func build_plan(available_actions: Array, static_actions: Array, primary_goals: Array, character: CombatCreatureBaseClass) -> Array:
	# Combine static and available actions
	var all_actions = available_actions + static_actions
	
	# Get the highest priority goal
	primary_goals.sort_custom(func (a, b): return a.goal_priority > b.goal_priority)

	# Initialize the plan as an empty array
	var plan: Array = []

	for goal in primary_goals:
		if build_node_plan("a*", plan, all_actions, character, goal, goal.goal_criteria):
			if plan.is_empty():
				continue
			else:
				plan.reverse()
				return plan
	return plan


# Recursively build a plan (One of A*, DFS, or BFS)(A* is the only implemented one at this time)
func build_node_plan(algorithm: String, plan: Array, actions: Array, character: CombatCreatureBaseClass, goal: AI_Goal, criteria: Dictionary) -> bool:
	match algorithm:
		"a*":
			# Base Case: Check if the current state already satisfies the goal
			if goal_criteria_is_already_satisfied(character, criteria):
				return true

			var valid_actions: Array = []
			var new_goal_criteria: Dictionary = {}
			for action in actions:
				if action.is_valid(character, criteria):
					valid_actions.append(action)
					# Add any preconditions to the new_goal_criteria list
					new_goal_criteria.merge(action.preconditions)

			# Improvement: Sorting
			##	- If multiple actions accomplish the same action, then it will become necessary to filter the actions down to the "best option"

			# If the criteria is already satisfied than remove them?


			# Iterate over valid actions and attempt to build a plan
			for action in valid_actions:

				# Create a hypothetical new state by applying the action
				var simulated_character: CombatCreatureBaseClass = action.apply(character, true)

				# Add the action to the current plan
				plan.append(action)

				# Recursively attempt to build the rest of the plan with the new state
				if build_node_plan("a*", plan, actions, simulated_character, goal, new_goal_criteria):
					return true

				# Backtrack if the current action did not lead to a valid plan
				plan.pop_back()
	return false


func goal_criteria_is_already_satisfied(character: CombatCreatureBaseClass, goal_criteria: Dictionary) -> bool:
	if goal_criteria.size() == 0:
		return true
	
	var tracker: bool = false
	for key in goal_criteria.keys():
		match typeof(goal_criteria[key]):
			TYPE_FLOAT:
				tracker = character.characteristics.get(key) == goal_criteria[key]
			TYPE_STRING:
				tracker = character.characteristics.get(key) == character.characteristics.get(goal_criteria[key])
			TYPE_BOOL:
				tracker = character.characteristics.get(key) == goal_criteria[key]
			TYPE_CALLABLE:
				tracker = goal_criteria[key].call(character)
			_:
				push_error("Goal Criteria type not defined [{goal_name}], [{goal_criteria_type}]".format({
					"goal_name": key,
					"goal_criteria_type": typeof(goal_criteria[key])
				}))
		if !tracker:
			return false
	return tracker
