extends Node

var Characteritics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd").new()

func calculate_time_to_reach_destination(speed: float, start_position: Vector2, desired_position: Vector2) -> float:
	# Calculate the distance between the two positions
	var distance = start_position.distance_to(desired_position)

	# Calculate the time to reach the target
	var time_to_reach = distance / speed

	print("Time to reach target: " + str(time_to_reach) + " seconds")
	
	return time_to_reach

func find_value_in_combat_creature_characteristics(key: String, characteristics: Dictionary):
	var found_value
	var flat_key = key.split(".")
	match len(flat_key):
		2: # <KEY>.<VALUE>, Example MOVEMENT.antsy
			var characteristic_key = Characteritics.get(flat_key[0])
			var found_characteristics = characteristics.get(characteristic_key)
			if found_characteristics:
				found_value = found_characteristics.get(flat_key[1], null)
				if found_value == null:
					push_warning("find_value_in_combat_creature_characteristics: found_value is null. Key: [{key}]".format({"key": key}))
	return found_value

func update_value_in_combat_creature_characteristics(key: String, value, characteristics: Dictionary) -> Dictionary:
	var flat_key = key.split(".")
	var new_characteristics = characteristics.duplicate()
	if len(flat_key) > 1:
		var characteristic_key = Characteritics.get(flat_key[0])
		var target_combat_creature_characteristic = new_characteristics.get(characteristic_key)
		var updated_target_combat_creature_characteristic = update_value_in_dictionary(flat_key[1], value, target_combat_creature_characteristic)
		new_characteristics.merge({characteristic_key: updated_target_combat_creature_characteristic}, true)
	return new_characteristics

func update_value_in_dictionary(key: String, value, state: Dictionary) -> Dictionary:
	match typeof(state[key]):
		TYPE_FLOAT:
			state[key] = clamp(state[key]+value, 0, state.get("max_{value}".format({"value": key}), 100)) 
		TYPE_INT:
			state[key] = clamp(state[key]+value, 0, state.get("max_{value}".format({"value": key}), 100)) 
		TYPE_BOOL:
			state[key] = value
	return state

