class_name AI_Utils

extends Node

func check_if_acceptable_distance(a: int, b: int) -> bool:
	var r = range(b+1, b+2)
	var tracker = a in range(b-2, b+2)
	return tracker
