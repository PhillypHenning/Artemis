extends Node

var healing_abilities = preload("res://scripts/combat/abilities/healing_abilities.gd")
var Healing_Abilities = healing_abilities.new()


var health = 5
var max_health = 10

func _ready() -> void:
	Healing_Abilities._init_healing_abilities(self)

func _on_button_pressed():
	#var id = 0
	#var target_ability = Healing_Abilities._get_ability_by_id(id)
	#var target_callable = target_ability["function"]
	#target_callable.callv([10])
	
	var id = 0
	var target_ability = Healing_Abilities.HEALING_ABILITIES[id]
	var target_callable = target_ability["function"]
	var target_parameters = target_ability["parameter_defaults"]
	target_parameters[0] = self
	target_callable.callv(target_parameters)
