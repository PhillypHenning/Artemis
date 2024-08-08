extends Node

class_name AI_Agent

const GoalPack = preload("res://scripts/combat/ai/goap/goal.gd")
const ActionPack = preload("res://scripts/combat/ai/goap/action.gd")
const PlannerPack = preload("res://scripts/combat/ai/goap/planner.gd")
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

var template_goal = GoalPack.new()

enum SEVERITY_LEVEL {
	NONE = 0,
	MINOR = 30,
	MIDDLING = 50,
	SEVERE = 70,
	DESPERATE = 90,
	MAX = 100,
}

var primary_goals: Array = []
var static_actions: Array = [
	ActionPack.new("DoTheAntsyShuffle", 
		{
			"current_antsy": func(a): return a > 1, # Precondition: Antsy should be lower than "0"
		},
		{	# Effects
			"current_antsy": float(-10),
		},
	),
	ActionPack.new("MoveIntoIdealRange", 
		{
			"distance_to_target": { # Precondition: distance_to_target != current_ideal_range
				"target_key": "current_ideal_range",
				"callable": func(a, b): return !AIUtils.check_if_acceptable_distance(a, b),
			},
		},
		{	# Effects
			"distance_to_target": { # Effect: distance_to_target = current_ideal_range
				"target_key": "current_ideal_range",
				"callable": func(a): return float(a),
				"apply": false
			},
		},
	),
	ActionPack.new("CircleEnemy",
		{
			"distance_to_target": { # Precondition: distance_to_target != current_ideal_range
				"target_key": "current_ideal_range",
				"callable": func(a, b): return AIUtils.check_if_acceptable_distance(a, b),
			},
		},
		{
		}
	)
]
var available_actions: Array = []

var game_start_time: float

var goal_keep_moving: Goal = GoalPack.new()
var character_node: CombatCreatureBaseClass


func _ready(): 
	primary_goals.append(
		template_goal.duplicate().new_goal_with_timer(
			"KeepMoving", # Goal Name
			calculate_keep_moving_priority, # Goal Priority Callable
			1, # Timer interval
			keep_moving_interval_increase, # Timer callable
			character_node, # Root Node to attach Timer to
			{ # Criteria
				"current_antsy": float(0)
			}
		)
	)
	primary_goals.append(
		template_goal.duplicate().new_goal_with_static_priority(
			"MoveToIdealRange", 	# Goal Name
			4,						# Goal Priority
			{						# Criteria
				"distance_to_target": { # Effect: distance_to_target = current_ideal_range
					"target_key": "current_ideal_range",
					"callable": func(a, b): return AIUtils.check_if_acceptable_distance(a, b)
				},
			}
		)
	)


# Takes an array of goals, runs the "calculate_goal_priority" function which either calls the goal callable or returns the static priority. Sorts the goals from highest priority to lowest.
func determine_goal_priority() -> void:
	var current_goal_priorities: Array = []
	for i in range(primary_goals.size()):
		primary_goals[i].calculate_goal_priority(character_node)
		current_goal_priorities.append(primary_goals[i].goal_priority)


func run_planner() -> Array:
	var planner = PlannerPack.new()
	return planner.build_plan(available_actions, static_actions, primary_goals, character_node.characteristics)


##-- GOAL CALCULATIONS --##
#func calculate_conserve_health_priority(_character: Object) -> float:
	#return goal_conserve_health.goal_priority


#func conserve_health_interval_decrease() -> void:
	#goal_conserve_health.goal_priority -= .5


func calculate_keep_moving_priority(character: Object) -> float:
	return character.characteristics.current_antsy


func keep_moving_interval_increase() -> void:
	var new_antsy = clamp((character_node.characteristics.current_antsy+.5), 0, character_node.characteristics.max_antsy)
	character_node.characteristics.current_antsy = new_antsy
