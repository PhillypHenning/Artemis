extends Node


func _get_timer_or_create(timers_group_node: Node, parameters: Dictionary, callable: Callable) -> Timer:
	var timer_node = timers_group_node.get_node_or_null(parameters.timer_name)
	if !timer_node:
		var timer = Timer.new()
		timer.name = parameters.timer_name
		timer.wait_time = parameters.wait_time
		timer.one_shot = parameters.one_shot
		timer.timeout.connect(callable.bind(parameters))
		timers_group_node.add_child(timer)
		return timer
	else:
		return timer_node
