extends Node

class_name AI_Agent

const GoalPack = preload("res://scripts/combat/ai/goap/goal.gd")
const ActionPack = preload("res://scripts/combat/ai/goap/action.gd")
const PlannerPack = preload("res://scripts/combat/ai/goap/planner.gd")
const UtilsPack = preload("res://scripts/combat/ai/goap/utils.gd")
var Utils = UtilsPack.new()

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
			"current_antsy": func(a): return a > 0, # Precondition: Antsy should be lower than "0"
		},
		{	# Effects
			"current_antsy": float(-1),
		}, 
	),
	ActionPack.new("MoveTowardsTarget", 
		{
			"target_in_attack_range": false
		},
		{	# Effects
			"target_in_attack_range": true
		},
	),
	ActionPack.new("BreakLineOfSight", 
		{	
			"has_los": true
		},
		{	# Effects
			"has_los": false,
		},
	),
]
var available_actions: Array = []

var game_start_time: float

var goal_keep_moving: Goal = GoalPack.new()
var goal_conserve_health: Goal = GoalPack.new()
var goal_attack_enemy: Goal = GoalPack.new()
var goal_defend_against_attack: Goal = GoalPack.new()
var character_node: CombatCreatureBaseClass


func _ready(): 
	# Improvements that could be made:
	##	1. conserve_health
	##		- Conserve health goes beyond breaking los though this is a good start. Another option for "Conserving health" would be to focus on defensive actions. In this scenario, when a creature takes damage it would temporarily boost the priority of the "defense_action" goal. 
	primary_goals.append(goal_keep_moving.new_goal_with_timer("keep_moving", calculate_keep_moving_priority, 1, keep_moving_interval_increase, character_node, {"current_antsy": float(0)}))
	#primary_goals.append(goal_conserve_health.new_goal_with_timer("conserve_health", calculate_conserve_health_priority, 2.5, conserve_health_interval_decrease, character_node, {"has_los": false}))
	#primary_goals.append(goal_attack_enemy.new_goal_with_static_priority("defeat_enemy", 4.5, {"defeat_enemy": true}))
	#primary_goals.append(goal_defend_against_attack.new_goal_with_static_priority("defense_action", 7, {"character_is_defending": true}))


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
func calculate_conserve_health_priority(_character: Object) -> float:
	return goal_conserve_health.goal_priority


func conserve_health_interval_decrease() -> void:
	goal_conserve_health.goal_priority -= .5


func calculate_keep_moving_priority(character: Object) -> float:
	return character.characteristics.current_antsy


func keep_moving_interval_increase() -> void:
	var new_antsy = clamp((character_node.characteristics.current_antsy+.3), 0, character_node.characteristics.max_antsy)
	character_node.characteristics.current_antsy = new_antsy
