extends Node

var ability_handler = preload("res://scripts/combat/abilities/abilities_handler.gd").new()
var healing_abilities = ability_handler.ABILITIES[ability_handler.HEALING]

var characteristics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd").new()
var combat_creature_health_characteristics = characteristics.combat_creature_characteristics[characteristics.HEALTH]

var reported_health = 0

@export var amount_healed: int = 3

func _ready() -> void:
	ability_handler._init_ability_handler(self)
	combat_creature_health_characteristics.current_health = 5
	combat_creature_health_characteristics.max_health = 10

func _process(_delta) -> void:
	if reported_health != combat_creature_health_characteristics.current_health:
		reported_health = combat_creature_health_characteristics.current_health
		print("current_health: {health}".format({"health": reported_health}))
	
	if Input.is_action_just_pressed("take_damage"):
		combat_creature_health_characteristics.current_health-=1

func _on_button_pressed():
	var ability = healing_abilities[ability_handler.HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME]
	ability.parameters.target = self
	ability.parameters.wait_time = 10
	ability.parameters.amount = amount_healed
	ability.parameters.timers_group_node = ability_handler.timers_group_node
	ability.target_callable.call(ability.parameters)
