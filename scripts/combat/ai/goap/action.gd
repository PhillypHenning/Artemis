class_name AI_Action

extends Resource

@export var action_name: String
@export var preconditions: Dictionary
@export var effects: Dictionary

func is_valid(cc_characteristics: CombatCreatureCharacteristics, goal_criteria: Dictionary) -> bool:
	var tracker: bool = false
	for key in goal_criteria:
		if preconditions.has(key):
			match typeof(preconditions[key]):
				TYPE_BOOL:
					tracker = cc_characteristics.get(key) == preconditions[key]
				TYPE_CALLABLE:
					tracker =  preconditions[key].call(cc_characteristics.get(key))
				TYPE_DICTIONARY:
					tracker =  preconditions[key].callable.call(cc_characteristics.get(key), cc_characteristics.get(preconditions[key].target_key))
				_:
					push_error("Precondition type not defined [{key}], [{key_type}]".format({
						"key": key,
						"key_type": typeof(preconditions[key])
					}))
			if !tracker: return tracker
	return tracker


func apply(cc_characteristics: CombatCreatureCharacteristics, simulate: bool = true) -> CombatCreatureCharacteristics:
	var new_cc_characteristics: CombatCreatureCharacteristics = cc_characteristics.deep_duplicate()

	for key in effects.keys():
		match typeof(effects[key]):
			TYPE_INT:
				var new_value = new_cc_characteristics.get(key) + effects[key]
				var max_key = key.replace("current", "max")
				new_cc_characteristics.key = clamp(new_value, 0, new_cc_characteristics.get(max_key))
			TYPE_FLOAT:
				var max_key = key.replace("current", "max")
				var new_value = clampf((new_cc_characteristics.get(key) + effects[key]), 0, new_cc_characteristics.get(max_key))
				new_cc_characteristics.set(key, new_value)
			TYPE_DICTIONARY:
				if simulate or effects[key].apply:
					new_cc_characteristics.set(key, effects[key].callable.call(new_cc_characteristics.get(effects[key].target_key)))
			_:
				push_error("Effect type not defined [{key}], [{key_type}]".format({
					"key": key,
					"key_type": typeof(effects[key])
				}))
	return new_cc_characteristics
