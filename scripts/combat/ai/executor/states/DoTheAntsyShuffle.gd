extends AI_State

func _init():
	state_name = "DoTheAntsyShuffle"

func action(character_node: CombatCreatureBaseClass) -> void:
	var rand_x = randf_range(-1, 1)
	var rand_y = randf_range(-1, 1)
	var new_position = Vector2(rand_x, rand_y)
	character_node._handle_combat_creature_basic_movement(new_position)

func is_complete(_character_node: CombatCreatureBaseClass) -> bool:
	return true
