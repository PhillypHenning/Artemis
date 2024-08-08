extends Node

class_name Action

var Utils = preload("res://scripts/combat/ai/goap/utils.gd").new()

var action_name: String
var preconditions: Dictionary = {}
var effects: Dictionary = {}
var cost: float = 0.0
var is_static_action: bool


func _init(init_action_name: String, init_preconditions: Dictionary, init_effects: Dictionary, init_cost: float = 0.0, init_is_static_action: bool = true):
	self.action_name = init_action_name
	self.preconditions = init_preconditions
	self.effects = init_effects
	self.cost = init_cost
	self.is_static_action = init_is_static_action


# is_valid takes the world state and a key
# It first checks if the action (self) has a precondition that matches the key
# It then checks the type of they key based on the world state.
#func is_valid(cc_characteristics: CombatCreatureCharacteristics, key) -> bool:
	#if preconditions.has(key):
		#match typeof(preconditions[key]):
			#TYPE_BOOL:
				#return cc_characteristics.get(key) == preconditions[key]
			#TYPE_CALLABLE:
				#return preconditions[key].call(cc_characteristics.get(key))
			#TYPE_DICTIONARY:
				#return preconditions[key].callable.call(cc_characteristics.get(key), cc_characteristics.get(preconditions[key].target_key))
			#_:
				#push_error("Precondition type not defined [{key}], [{key_type}]".format({
					#"key": key,
					#"key_type": typeof(preconditions[key])
				#}))
	#return false

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


func apply(cc_characteristics: CombatCreatureCharacteristics) -> CombatCreatureCharacteristics:
	var new_cc_characteristics: CombatCreatureCharacteristics = cc_characteristics
	var check_cc_characteristics: CombatCreatureCharacteristics = cc_characteristics.duplicate()
	#check_cc_characteristics = cc_characteristics
	check_cc_characteristics.current_antsy = 100
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
				new_cc_characteristics.set(key, effects[key].callable.call(new_cc_characteristics.get(effects[key].target_key)))
			_:
				push_error("Effect type not defined [{key}], [{key_type}]".format({
					"key": key,
					"key_type": typeof(effects[key])
				}))
	return new_cc_characteristics
