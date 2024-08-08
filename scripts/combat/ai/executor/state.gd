class_name AI_State

extends Resource

@export var state_name: String = ""

func run_action(_character_node: CombatCreatureBaseClass):
	push_error("Template function. Override this in the child state object")

func is_complete(_character_node: CombatCreatureBaseClass) -> bool:
	push_error("Template function. Override this in the child state object")
	return false
