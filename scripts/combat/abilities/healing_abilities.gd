extends Node

var HEALING_ABILITIES = [
	{
		"id": 0,
		"function": _heal_to_full_after_time,
		"parameter_defaults": [null, 10, true]
	},
]

func _init_healing_abilities(parent_node: Node) -> void:
	var healing_abilities_timers_node_group = Node.new()
	healing_abilities_timers_node_group.name = "AbilityTimers"
	parent_node.add_child(healing_abilities_timers_node_group)


func _heal_to_full_after_time(target: Node, wait_time: int, one_shot: bool) -> void:
	print(target)
	print(target.find_child("AbilityTimers"))
	

	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	timer.name = "HealToFullAfterTime"
	timer.timeout.connect(_act_on_heal_to_full_after_time_timeout.bind(target))
	print(target.find_child("AbilityTimers"))
	target.add_child(timer)
	if timer.is_stopped():
		timer.start()


func _act_on_heal_to_full_after_time_timeout(target: Node) -> void:
	print("_act_on_heal_to_full_after_time_timeout called")
	print(target.health)
	print(target.max_health)
