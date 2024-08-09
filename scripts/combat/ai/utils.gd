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
