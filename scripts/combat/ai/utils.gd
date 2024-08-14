class_name AI_Utils

extends Node

func check_if_acceptable_distance(value1: float, value2: float) -> bool:
	# Calculate the average value to use as a reference for tolerance
	var average_value = (value1 + value2) / 2.0
	# Calculate the tolerance (1% of the average value)
	var tolerance = average_value * 0.01
	# Calculate the absolute difference between the two values
	var difference = abs(value1 - value2)
	# Check if the difference is within the tolerance
	return difference <= tolerance

func check_if_target_in_range(character: CombatCreatureBaseClass, target_position: Vector2, distance: float) -> bool:
	# var target_distance = character.position.distance_to(character.characteristics.enemy_target.position) - distance
	var target_distance = character.position.distance_to(target_position) - distance
	var epsilon = 0.001  # Define a small enough value to consider as close to zero
	var abs_value = abs(target_distance)
	return abs_value <= epsilon

func calculate_time_to_reach_destination(speed: float, start_position: Vector2, desired_position: Vector2) -> float:
	# Calculate the distance between the two positions
	var distance = start_position.distance_to(desired_position)

	# Calculate the time to reach the target
	var time_to_reach = distance / speed

	print("Time to reach target: " + str(time_to_reach) + " seconds")
	
	return time_to_reach

func load_resources_to_dict(resource_path: String, extension: String) -> Dictionary:
	var discovered_resources: Dictionary ={}
	for file_name in DirAccess.get_files_at(resource_path):
		if (file_name.get_extension() == extension):
			var state = file_name.replace("."+extension, '')
			var loaded_resource = load(resource_path+"/"+file_name).new()
			discovered_resources.merge({state: loaded_resource})
	return discovered_resources

func load_resources_to_array(resource_path: String, extension: String, character: CombatCreatureBaseClass = null) -> Array:
	var discovered_resources: Array = []
	for file_name in DirAccess.get_files_at(resource_path):
		if (file_name.get_extension() == extension):
			var loaded_resource
			if character:
				loaded_resource = load(resource_path+"/"+file_name).new(character)
			else:
				loaded_resource = load(resource_path+"/"+file_name).new()
			discovered_resources.append(loaded_resource)
	return discovered_resources
