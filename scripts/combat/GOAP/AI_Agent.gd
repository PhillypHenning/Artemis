extends Node

class_name AI_Agent

const GoalPack = preload("res://scripts/combat/GOAP/Goal.gd")
const ActionPack = preload("res://scripts/combat/GOAP/Action.gd")
const PlannerPack = preload("res://scripts/combat/GOAP/Planner.gd")
const UtilsPack = preload("res://scripts/combat/GOAP/Utils.gd")
const Characteristics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd")
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
var current_plan: Array = []
var static_actions: Array = [
	ActionPack.new("DoTheAntsyShuffle", 
		{
			"antsy": func(a): return a > 0, # Precondition: Antsy should be lower than "0"
		},
		{	# Effects
			"antsy": -1,
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

# Debug
var current_plan_text: TextEdit
var goals_textbox: TextEdit


func _ready(): 
	# Improvements that could be made:
	##	1. conserve_health
	##		- Conserve health goes beyond breaking los though this is a good start. Another option for "Conserving health" would be to focus on defensive actions. In this scenario, when a creature takes damage it would temporarily boost the priority of the "defense_action" goal. 
	primary_goals.append(goal_keep_moving.new_goal_with_timer("keep_moving", calculate_keep_moving_priority, 1, keep_moving_interval_increase, get_parent(), {"{1}.antsy".format({1:Characteristics.MOVEMENT}): 0}))
	#primary_goals.append(goal_conserve_health.new_goal_with_timer("conserve_health", calculate_conserve_health_priority, 2.5, conserve_health_interval_decrease, get_parent(), {"has_los": false}))
	#primary_goals.append(goal_attack_enemy.new_goal_with_static_priority("defeat_enemy", 4.5, {"defeat_enemy": true}))
	#primary_goals.append(goal_defend_against_attack.new_goal_with_static_priority("defense_action", 7, {"character_is_defending": true}))

	character_node = get_parent()
	
	# Debug
	var root_node = get_tree().current_scene
	current_plan_text = root_node.find_child("CurrentPlanText")
	goals_textbox = root_node.find_child("GoalsText")
	

func _init():
	game_start_time = Time.get_unix_time_from_system()


func _process(_delta: float) -> void:
	determine_goal_priority()
	run_planner()
	#check_if_enemy_is_defeated()
	
	# DEBUG
	debug_available_plan()
	debug_goals()





# Takes an array of goals, runs the "calculate_goal_priority" function which either calls the goal callable or returns the static priority. Sorts the goals from highest priority to lowest.
func determine_goal_priority():
	var current_goal_priorities: Array = []
	for i in range(primary_goals.size()):
		primary_goals[i].calculate_goal_priority(character_node)
		current_goal_priorities.append(primary_goals[i].goal_priority)

func run_planner() -> void:
	var planner = PlannerPack.new()
	current_plan = planner.build_plan(available_actions, static_actions, primary_goals, character_node)





##-- GOAL CALCULATIONS --##
func calculate_conserve_health_priority(_character: Object) -> float:
	return goal_conserve_health.goal_priority

func conserve_health_interval_decrease() -> void:
	goal_conserve_health.goal_priority -= .5

func calculate_keep_moving_priority(character: Object) -> float:
	return character.combat_creature_movement_characteristics.antsy

func keep_moving_interval_increase() -> void:
	character_node.combat_creature_movement_characteristics.antsy = clamp((character_node.combat_creature_movement_characteristics.antsy+.3), 0, character_node.combat_creature_movement_characteristics.max_antsy)

#func check_if_enemy_is_defeated() -> void:
	#simulated_character.defeat_enemy = false
##-- -------------- --##





##-- DEBUG --##
func debug_available_plan() -> void:
	var text_string: String
	text_string = "Current Plan:"
	for action in current_plan:
		text_string = "{text_string}\n\tAction: [{name}]".format({"text_string": text_string, "name": action.action_name})
	
	if current_plan_text:
		current_plan_text.text = text_string

func debug_goals() -> void:
	var goals_text: String
	goals_text = "Current Goals:"
	for goal in primary_goals:
		goals_text = "{goal_text}\nGoal: [{goal}]\n\tPriority: [{priority}]\n\tCriteria:".format({"goal_text": goals_text, "goal": goal.goal_name, "priority": goal.goal_priority})
		for criteria in goal.goal_criteria:
			goals_text = "{goal_text}\n\t\t[{criteria}] : [{value}]".format({"goal_text": goals_text, "criteria": criteria, "value": goal.goal_criteria[criteria]})
	if goals_textbox:
		goals_textbox.text = goals_text
##-- ----- --##
