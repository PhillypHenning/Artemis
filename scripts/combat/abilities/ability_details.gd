class_name AbilityResource
extends Resource

var offensive_melee_attacks = preload("res://scripts/combat/abilities/offensive/offensive_melee_attacks.gd").new()

enum OFFENSIVE_TYPES {
	MELEE,
	RANGE
}

enum OFFENSIVE_MELEE_IDS {
	CLOSE_RANGE_MELEE_TEST_ATTACK
}

var offensive_abilities: Dictionary = {
	OFFENSIVE_TYPES.MELEE: {
		OFFENSIVE_MELEE_IDS.CLOSE_RANGE_MELEE_TEST_ATTACK:{
			"callable": null,
			"defaults": {
				
			}
		}
	},
	OFFENSIVE_TYPES.RANGE: {
		
	}
}
