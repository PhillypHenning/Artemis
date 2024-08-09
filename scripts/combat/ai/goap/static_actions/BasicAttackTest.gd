extends AI_Action

func _init() -> void:
	action_name = "BasicAttackTest"
	#preconditions = {
		#"is_attacking": false,
		#"distance_to_target": determine_character_in_range
	#}
	#effects = {
		#"is_attacking": true
	#}

# Preconditions:
#	Combat Creature can't already be attacking
#	Combat Creature should be in range to make the attack
# 	Combat Creature needs to have enough stamina to make the attack

# Effects:
# 	The Combat Creature will now be attacking
# 	The Combat Creature will use Stamina


func determine_character_in_range(character: CombatCreatureBaseClass) -> bool:
	var distance = character.position.distance_to(character.characteristics.enemy_target.position)
	return !AIUtils.check_if_acceptable_distance(distance, CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE)
