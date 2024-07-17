extends Node

var ability_handler = preload("res://scripts/combat/abilities/abilities_handler.gd").new()
var healing_abilities = ability_handler.ABILITIES[ability_handler.HEALING]
var offensive_abilities = ability_handler.ABILITIES[ability_handler.OFFENSIVE][ability_handler.OFFENSIVE_ABILITY_TYPES.TEST]

var reported_health = 0

@export var amount_healed: int = 3
@onready var target_dummy = $TargetDummy

func _ready() -> void:
	ability_handler._init_ability_handler(self)
	_on_target_dummy_reset_pressed()

func _process(_delta) -> void:
	pass

func _on_target_dummy_reset_pressed():
	target_dummy.combat_creature_health_characteristics.current_health = 5
	target_dummy.combat_creature_health_characteristics.max_health = 10


func _on_heal_over_time_ability_button_pressed():
	print("Heal Over Time Ability Test Started")
	var ability = healing_abilities[ability_handler.HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME]
	ability.parameters.target = target_dummy
	ability.parameters.wait_time = 10
	ability.parameters.amount = amount_healed
	ability.parameters.timers_group_node = ability_handler.timers_group_node
	ability.target_callable.call(ability.parameters)


func _on_close_melee_attack_ability_button_pressed():
	print("Close Melee Attack Test Started")
	var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_CLOSE_MELEE]
	ability.parameters.target = target_dummy
	ability.parameters.amount = 1
	ability.target_callable.call(ability.parameters)
