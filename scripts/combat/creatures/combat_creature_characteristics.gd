class_name CombatCreatureCharacteristics

extends Resource

enum CHARACTER_TYPE {
	PLAYER,
	NPC_FRIENDLY,
	NPC_NEUTRAL,
	NPC_ENEMY
}

# enum SEVERITY_LEVEL {
# 	NONE = 0,
# 	TRIVIAL = 10,
# 	MINOR = 30,
# 	MIDDLING = 50,
# 	SEVERE = 70,
# 	DESPERATE = 90,
# 	MAX = 100,
# }

enum PROXIMITY {
	MELEE_CLOSE = 50,
	MELEE_MEDIUM = 100,
	MELEE_FAR = 150,
	DEADZONE = 250,
	RANGE_CLOSE = 350,
	RANGE_FAR = 450,
	OOMR,
}

# -- DETAILS -- #
@export var character_type: CHARACTER_TYPE
@export var character_name: String
# -- HEALTH -- #
@export var current_health: float
@export var max_health: float
#var health_severity: SEVERITY_LEVEL
@export var is_dead: bool
@export var can_take_damage: bool
@export var can_take_damage_after_time: float
# -- STAMINA -- #
@export var current_stamina: int
@export var max_stamina: int
# -- MOVEMENT -- #
@export var starting_speed: float
@export var current_speed: float
const max_speed: float = 1000
@export var is_using_movement_ability: bool
@export var current_antsy: float
const max_antsy: int = 10
# -- EVASION -- #
@export var is_using_evasive_ability: bool
@export var has_iframes: bool
@export var time_length_of_iframes: float
# -- ATTACKING -- #
@export var is_attacking: bool
# -- TARGETTING -- #
@export var enemy_targets: Array
@export var friendly_targets: Array
var enemy_target: CharacterBody2D
var friendly_target: CharacterBody2D
# -- LINE OF SIGHT -- #
@export var los_on_targets: Dictionary
@export var los_on_target: bool
# -- IDEAL RANGE -- #
@export var current_ideal_range: PROXIMITY
@export var distance_to_target: float

func deep_duplicate() -> CombatCreatureCharacteristics:
	var new_ccc = self.duplicate(true)
	new_ccc.enemy_target = self.enemy_target
	new_ccc.friendly_target = self.friendly_target
	return new_ccc

# func calculate_severity_level(state: Dictionary, key: String, reversed: bool = false) -> Dictionary:
# 	var severity_current =  state.get("current_{key}".format({"key": key}), false)
# 	var severity_max = state.get("max_{key}".format({"key": key}), false)
# 	var severity = state.get("{key}_severity".format({"key": key}), false)

# 	if severity_current == severity_max:
# 		if reversed:
# 			severity = SEVERITY_LEVEL.MAX
# 		else:
# 			severity = SEVERITY_LEVEL.NONE
# 	else:
# 		var formula: float
# 		if reversed:
# 			formula = ((severity_current / severity_max) * 100)
# 		else:
# 			formula = 100 - ((severity_current / severity_max) * 100)
# 		if formula == SEVERITY_LEVEL.MAX:
# 			severity = SEVERITY_LEVEL.MAX
# 		elif formula >= SEVERITY_LEVEL.DESPERATE:
# 			severity = SEVERITY_LEVEL.DESPERATE
# 		elif formula >= SEVERITY_LEVEL.SEVERE:
# 			severity = SEVERITY_LEVEL.SEVERE
# 		elif formula >= SEVERITY_LEVEL.MIDDLING:
# 			severity = SEVERITY_LEVEL.MIDDLING
# 		elif formula >= SEVERITY_LEVEL.MINOR:
# 			severity = SEVERITY_LEVEL.MINOR
# 		elif formula > SEVERITY_LEVEL.NONE:
# 			severity = SEVERITY_LEVEL.TRIVIAL
# 		else:
# 			severity = SEVERITY_LEVEL.NONE
# 	state["{key}_severity".format({"key": key})] = severity
# 	return state
