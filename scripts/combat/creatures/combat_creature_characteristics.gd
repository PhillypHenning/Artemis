class_name CombatCreatureCharacteristics

extends Node

enum CHARACTER_TYPE {
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

enum PROXIMITY {
	MELEE_CLOSE = 75,
	MELEE_MEDIUM = 175,
	MELEE_FAR = 300,
	OOMR
}

# -- DETAILS -- #
var character_type: CHARACTER_TYPE
var character_name: String
# -- HEALTH -- #
var current_health: float
var max_health: float
var health_severity: SEVERITY_LEVEL
var is_dead: bool
var can_take_damage: bool
var can_take_damage_after_time: float
# -- STAMINA -- #
var current_stamina: int
var max_stamina: int
# -- MOVEMENT -- #
var starting_speed: float
var current_speed: float
const max_speed: float = 1000
var is_using_movement_ability: bool
var current_antsy: float
const max_antsy: int = 10
# -- EVASION -- #
var is_using_evasive_ability: bool
var has_iframes: bool
var time_length_of_iframes: float
# -- ATTACKING -- #
var is_attacking: bool
# -- TARGETTING -- #
var enemy_targets: Array
var friendly_targets: Array
var enemy_target: CharacterBody2D
var friendly_target: CharacterBody2D
# -- LINE OF SIGHT -- #
var los_on_targets: Dictionary
var los_on_target: bool
# -- IDEAL RANGE -- #
var current_ideal_range: PROXIMITY


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

