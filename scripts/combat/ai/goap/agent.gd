class_name AI_Agent

extends Node

const PlannerPack = preload("res://scripts/combat/ai/goap/planner.gd")

var character_node: CombatCreatureBaseClass

var primary_goals: Array = []
var static_actions: Array = []
var available_actions: Array = []
var planner = PlannerPack.new()

func _ready():
	var deadzone_action_test = load("res://scripts/combat/ai/goap/actions/MoveIntoDeadzone.tres")
	var antsy_action_test = load("res://scripts/combat/ai/goap/actions/DoTheAntsyShuffle.tres")
	static_actions.append(deadzone_action_test)
	static_actions.append(antsy_action_test)
	
	var deadzone_goal_test = load("res://scripts/combat/ai/goap/goals/MoveIntoDeadzone.gd").new(character_node)
	primary_goals.append(deadzone_goal_test)
	var antsy_goal_test = load("res://scripts/combat/ai/goap/goals/DoTheAntsyShuffle.gd").new(character_node)
	primary_goals.append(antsy_goal_test)


# Takes an array of goals, runs the "calculate_goal_priority" function which either calls the goal callable or returns the static priority. Sorts the goals from highest priority to lowest.
func determine_goal_priority() -> void:
	var current_goal_priorities: Array = []
	for i in range(primary_goals.size()):
		primary_goals[i].calculate_priority()
		current_goal_priorities.append(primary_goals[i].goal_priority)


func run_planner() -> Array:
	return planner.build_plan(available_actions, static_actions, primary_goals, character_node.characteristics)
