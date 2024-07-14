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

var combat_creature_characteristics: Dictionary = {
	TYPE: {
		character_type = null
	},
	DETAILS : {
		name: ""
	},
	HEALTH: {
		starting_health = 0,
		current_health = 0,
		max_health = 0,
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
		is_using_movement_ability = false
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
