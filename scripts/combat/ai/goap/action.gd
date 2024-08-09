class_name AI_Action

extends Resource

@export var action_name: String
@export var preconditions: Dictionary
@export var effects: Dictionary
var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

func is_valid(chracter: CombatCreatureBaseClass, goal_criteria: Dictionary) -> bool:
	var tracker: bool = false
	for key in goal_criteria:
		if preconditions.has(key):
			match typeof(preconditions[key]):
				TYPE_BOOL:
					tracker = chracter.characteristics.get(key) == preconditions[key]
				TYPE_CALLABLE:
					#tracker =  preconditions[key].call(chracter.characteristics.get(key))
					tracker = preconditions[key].call(chracter)
				TYPE_DICTIONARY:
					tracker =  preconditions[key].callable.call(chracter.characteristics.get(key), chracter.characteristics.get(preconditions[key].target_key))
				_:
					push_error("Precondition type not defined [{key}], [{key_type}]".format({
						"key": key,
						"key_type": typeof(preconditions[key])
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
			TYPE_INT:
				var new_value = new_character.characteristics.get(key) + effects[key]
				var max_key = key.replace("current", "max")
				new_character.characteristics.key = clamp(new_value, 0, new_character.characteristics.get(max_key))
			TYPE_FLOAT:
				var max_key = key.replace("current", "max")
				var new_value = clampf((new_character.characteristics.get(key) + effects[key]), 0, new_character.characteristics.get(max_key))
				new_character.characteristics.set(key, new_value)
			TYPE_DICTIONARY:
				if effects[key].apply or simulate:
					new_character = effects[key].callable.call(new_character)
			TYPE_BOOL:
				new_character.characteristics.set(key, effects[key])
			TYPE_CALLABLE:
				new_character = effects[key].call(new_character)
			_:
				push_error("Effect type not defined [{key}], [{key_type}]".format({
					"key": key,
					"key_type": typeof(effects[key])
				}))
	return new_character


func print() -> String:
	var header = "\tAction: [%s]" % action_name
	var pc_text: String
	for precondition in preconditions:
		match typeof(preconditions[precondition]):
			TYPE_CALLABLE:
				pc_text = "%s\n\t\t%s: Callable" % [pc_text, precondition]
			TYPE_DICTIONARY:
				pc_text = "%s\n\t\t%s:" % [pc_text, precondition]
				for key in preconditions[precondition]:
					pc_text = "%s\n\t\t\t%s" % [pc_text, key]
	return header + pc_text
