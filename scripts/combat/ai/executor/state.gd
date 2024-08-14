class_name AI_State

extends Resource
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

var state_name: String = ""
var target_action_properties: Dictionary
var target_is_complete: Callable
var action_timer: Callable
var update: Callable

func run_action(_character_node: CombatCreatureBaseClass):
	push_error("Template function. Override this in the child state object")

func is_complete(_character_node: CombatCreatureBaseClass) -> bool:
	push_error("Template function. Override this in the child state object")
	return false
