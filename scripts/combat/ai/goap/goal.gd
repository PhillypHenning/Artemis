class_name AI_Goal

extends Node

const MIN_PRIORITY = 0
const MAX_PRIORITY = 10

@export var goal_name: String
@export var goal_criteria: Dictionary
@export var goal_priority: float
@export var goal_timer_interval: float
@export var cc_character: CombatCreatureBaseClass
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()
var target_group_name = "CharacterAIGoals"

func is_satisfied(agent_state: Dictionary) -> bool:
	var tracker: bool = false
	for key in goal_criteria.keys():
		tracker = agent_state.get(key) == goal_criteria[key]
		if !tracker:
			return false
	return tracker

func calculate_priority() -> float:
	return self.goal_priority
