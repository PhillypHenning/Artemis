class_name AI_Agent

extends Node

const PlannerPack = preload("res://scripts/combat/ai/goap/planner.gd")
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()
var planner = PlannerPack.new()

var character_node: CombatCreatureBaseClass

var primary_goals: Array
var static_actions: Array
var available_actions: Array

var actions_path: String = "res://scripts/combat/ai/goap/static_actions"
var goals_path: String = "res://scripts/combat/ai/goap/goals"

func _ready():
	static_actions = AIUtils.load_resources_to_array(actions_path, "gd")
	primary_goals = AIUtils.load_resources_to_array(goals_path, "gd", character_node)


# Takes an array of goals, runs the "calculate_goal_priority" function which either calls the goal callable or returns the static priority. Sorts the goals from highest priority to lowest.
func determine_goal_priority() -> void:
	var current_goal_priorities: Array = []
	for i in range(primary_goals.size()):
		primary_goals[i].calculate_priority()
		current_goal_priorities.append(primary_goals[i].goal_priority)


func run_planner() -> Array:
	return planner.build_plan(available_actions, static_actions, primary_goals, character_node)
