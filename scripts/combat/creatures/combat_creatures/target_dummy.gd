extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400

var target_dummy_has_taken_damage: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_creature_name = "Target Dummy Card"
	super._ready()
	_init_initial_stat_set(health, stamina, speed)

func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("take_damage"):
		_use_combat_creature_take_damage(1)
		if !target_dummy_has_taken_damage:
			target_dummy_has_taken_damage = true

	if Input.is_action_just_pressed("use_stamina"):
		_use_combat_creature_use_stamina(1)

func _init_attach_creature_to_card(card: Node):
	combat_creature_card = card
	super._init_combat_card()

func _init_assign_target(target: Node) -> void:
	combat_creature_target = target
