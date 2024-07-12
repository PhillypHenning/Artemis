extends Node

func _heal_to_full_after_time(target: Node, ability_properties: Dictionary) -> void:
	var timers_group_node = target.get_node("AbilityTimers")
	var htfat_node = timers_group_node.get_node_or_null(ability_properties.timer_name)

	if htfat_node == null:
		var timer = Timer.new()
		timer.name = ability_properties.timer_name
		timer.wait_time = ability_properties.parameters.wait_time
		timer.one_shot = ability_properties.parameters.one_shot
		timer.timeout.connect(_act_on_heal_to_full_after_time_timeout.bind(target, ability_properties))
		timers_group_node.add_child(timer)
		timer.start()

func _act_on_heal_to_full_after_time_timeout(target: Node, ability_properties: Dictionary) -> void:
	ability_properties.parameters.target.combat_creature_health_characteristics.current_health = clamp(ability_properties.parameters.target.combat_creature_health_characteristics.current_health + ability_properties.parameters.amount, 0, ability_properties.parameters.target.combat_creature_health_characteristics.max_health)
	var htfat_node = ability_properties.parameters.target.get_node("AbilityTimers").get_node("HealToFullAfterTime")
	htfat_node.queue_free()
