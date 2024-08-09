extends AI_Goal

func _init(character: CombatCreatureBaseClass):
	self.goal_name = "PerformAttack"
	self.goal_criteria = {
		"is_attacking": true
	}
	self.goal_priority = 4
	self.cc_character = character

# The goal wants to combat creature to make an attack if it can do so
