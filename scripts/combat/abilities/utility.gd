extends Node

var id_to_ability = {
	1: _ability_handle_heal_to_full_after_time
}

func _ability_handle_heal_to_full_after_time(state) -> void:
	print("_ability_handle_heal_after_time called")
