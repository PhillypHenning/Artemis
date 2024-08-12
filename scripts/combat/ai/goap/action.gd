class_name AI_Action

extends Resource

@export var action_name: String
@export var preconditions: Dictionary
@export var effects: Dictionary
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

func is_valid(character: CombatCreatureBaseClass, goal_criteria: Dictionary) -> bool:
	var tracker: bool = false
	# Creature the simulated character
	var simulated_character = character.duplicate()
	simulated_character.characteristics = character.characteristics.deep_duplicate()
	
	for key in goal_criteria:
		if effects.has(key):
			match typeof(effects[key]):
				TYPE_BOOL:
					# Easiest of the testables
					# If the effect will result in the goal_criteria request, then life is good, proceed.
					tracker = effects[key] == goal_criteria[key]
				
				TYPE_DICTIONARY:
					var validate_callable = effects[key].get("validate")
					tracker = validate_callable.call(simulated_character, goal_criteria.get(key))
				_:
					push_error("Effect type not defined [{key}], [{key_type}]".format({
						"key": key,
						"key_type": typeof(effects[key])
					}))
			if !tracker: return tracker
	return tracker


func apply(character: CombatCreatureBaseClass, simulate: bool = true) -> CombatCreatureBaseClass:
	var new_character: CombatCreatureBaseClass 
	if simulate:
		new_character = character.duplicate()
		new_character.characteristics = character.characteristics.deep_duplicate()
	else:
		new_character = character

	for key in effects.keys():
		match typeof(effects[key]):
			TYPE_BOOL:
				new_character.characteristics.set(key, effects[key])
			TYPE_DICTIONARY:
				if simulate or !effects[key].get("simulate_only", false):
					var apply_callable = effects[key].get("apply")
					apply_callable.call(new_character)
			_:
				push_error("Effect type not defined [{key}], [{key_type}]".format({
					"key": key,
					"key_type": typeof(effects[key])
				}))
	return new_character


func print() -> String:
	var header = "\tAction: [%s]" % action_name
	return header
