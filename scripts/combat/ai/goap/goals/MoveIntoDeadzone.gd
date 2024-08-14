extends AI_Goal

var distance: float

func _init(character: CombatCreatureBaseClass):
	self.goal_name = "MoveIntoDeadzone"
	distance = CombatCreatureCharacteristics.PROXIMITY.DEADZONE
	self.goal_criteria = {
				"distance_to_target": determine_character_in_deadzone
	}
	self.goal_priority = 2
	self.cc_character = character

func determine_character_in_deadzone(character: CombatCreatureBaseClass) -> bool:
	# Character position - distance should = the characters distance_to_target value
	return AIUtils.check_if_target_in_range(character, character.characteristics.enemy_target.position, distance)
