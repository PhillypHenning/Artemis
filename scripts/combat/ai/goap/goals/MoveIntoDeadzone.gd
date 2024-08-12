extends AI_Goal

func _init(character: CombatCreatureBaseClass):
	self.goal_name = "MoveIntoDeadzone"
	self.goal_criteria = {
				"distance_to_target": determine_character_in_deadzone
	}
	self.goal_priority = 2
	self.cc_character = character

func determine_character_in_deadzone(character: CombatCreatureBaseClass) -> bool:
	return AIUtils.check_if_acceptable_distance(character.characteristics.distance_to_target, CombatCreatureCharacteristics.PROXIMITY.DEADZONE)
