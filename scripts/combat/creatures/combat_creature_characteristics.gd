extends Node

enum {
	TYPE,
	DETAILS,
	HEALTH,
	STAMINA,
	MOVEMENT,
	DODGING,
	DASHING,
	ATTACKING
}

enum {
	PLAYER,
	NPC_FRIENDLY,
	NPC_NEUTRAL,
	NPC_ENEMY
}

enum SEVERITY_LEVEL {
	NONE = 0,
	TRIVIAL = 10,
	MINOR = 30,
	MIDDLING = 50,
	SEVERE = 70,
	DESPERATE = 90,
	MAX = 100,
}


var combat_creature_characteristics: Dictionary = {
	TYPE: {
		character_type = null
	},
	DETAILS : {
		name: ""
	},
	HEALTH: {
		starting_health = 0.0,
		current_health = 0.0,
		max_health = 0.0,
		health_severity = SEVERITY_LEVEL.NONE,
		is_dead = false,
		can_take_damage = true,
		can_take_damage_after_time = .25
	},
	STAMINA : {
		starting_stamina = 0,
		current_stamina = 0,
		max_stamina = 0
	},
	MOVEMENT: {
		starting_speed = 0,
		current_speed = 0,
		max_speed = 0,
		is_using_movement_ability = false,
		antsy = 0.0,
		max_antsy = 10.0,
	},
	DODGING: {
		is_dodging = false,
		has_iframes = false,
		time_length_of_iframes = 0,
	},
	DASHING: {
		is_dashing = false,	
	},
	ATTACKING: {
		is_attacking = false
	}
}



func calculate_severity_level(state: Dictionary, key: String, reversed: bool = false) -> Dictionary:
	var severity_current =  state.get("current_{key}".format({"key": key}), false)
	var severity_max = state.get("max_{key}".format({"key": key}), false)
	var severity = state.get("{key}_severity".format({"key": key}), false)

	if severity_current == severity_max:
		if reversed:
			severity = SEVERITY_LEVEL.MAX
		else:
			severity = SEVERITY_LEVEL.NONE
	else:
		var formula: float
		if reversed:
			formula = ((severity_current / severity_max) * 100)
		else:
			formula = 100 - ((severity_current / severity_max) * 100)
		if formula == SEVERITY_LEVEL.MAX:
			severity = SEVERITY_LEVEL.MAX
		elif formula >= SEVERITY_LEVEL.DESPERATE:
			severity = SEVERITY_LEVEL.DESPERATE
		elif formula >= SEVERITY_LEVEL.SEVERE:
			severity = SEVERITY_LEVEL.SEVERE
		elif formula >= SEVERITY_LEVEL.MIDDLING:
			severity = SEVERITY_LEVEL.MIDDLING
		elif formula >= SEVERITY_LEVEL.MINOR:
			severity = SEVERITY_LEVEL.MINOR
		elif formula > SEVERITY_LEVEL.NONE:
			severity = SEVERITY_LEVEL.TRIVIAL
		else:
			severity = SEVERITY_LEVEL.NONE
	state["{key}_severity".format({"key": key})] = severity
	return state
