extends CombatCreatureBaseClass

@export var health: 	int = 100
@export var stamina: 	int = 10
@export var speed: 		int = 400
var reported_health = 0

var ability_handler = preload("res://scripts/combat/abilities/abilities_handler.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_creature_details.name = "Target Dummy"
	super._ready()
	_init_initial_stat_set(health, stamina, speed)
	ability_handler._init_ability_handler(self)

func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("take_damage"):
		_use_combat_creature_take_damage(1)
		_use_heal_to_full_ability()

	if Input.is_action_just_pressed("use_stamina"):
		_use_combat_creature_use_stamina(1)
		
	if reported_health != combat_creature_health_characteristics.current_health:
		reported_health = combat_creature_health_characteristics.current_health

func _init_attach_creature_to_card(card: Node):
	combat_creature_nodes[COMBAT_CARD].node = card
	super._init_combat_card()

func _init_assign_target(target: Node) -> void:
	combat_creature_nodes[TARGETTING].enemy_target = target

func _use_heal_to_full_ability() -> void:
	var ability = ability_handler.ABILITIES[ability_handler.HEALING][ability_handler.HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME]
	ability.parameters.target = self
	ability.parameters.wait_time = 10 # WILL BE REPLACED IN healing_abilities.gd with an evaluation based on creature stats
	ability.parameters.amount = 100 	# WILL BE REPLACED IN healing_abilities.gd with an evaluation based on creature stats
	ability.target_callable.call(self, ability)
