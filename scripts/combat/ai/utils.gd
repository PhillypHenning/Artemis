class_name AI_Utils

extends Node

func check_if_acceptable_distance(a: int, b: int) -> bool:
	var trange = range(b-2, b+2)
	var tracker = a in trange
	return tracker

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
