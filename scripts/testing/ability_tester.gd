extends Node

var ability_handler = preload("res://scripts/combat/abilities/abilities_handler.gd").new()

var reported_health = 0
var health = 5
var max_health = 10

@export var amount_healed: int = 3

func _ready() -> void:
	ability_handler._init_ability_handler(self)

func _process(_delta) -> void:
	if reported_health != health:
		reported_health = health
		print("current_health: {health}".format({"health": reported_health}))
	
	if Input.is_action_just_pressed("take_damage"):
		health-=1

func _on_button_pressed():
	var ability = ability_handler.ABILITIES[ability_handler.ABILITIES_IDS.HEALING][ability_handler.HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME]
	ability.parameters_overrides.target = self
	ability.parameters_overrides.wait_time = 10
	#ability.parameters_overrides.amount = 100
	ability.parameters_overrides.amount = amount_healed
	ability.target_callable.call(self, ability)
