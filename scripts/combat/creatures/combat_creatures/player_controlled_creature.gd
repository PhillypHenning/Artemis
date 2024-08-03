extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characteristics.character_type = CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER
	characteristics.character_name = "Player Controlled Creature"
	super._ready()
	_init_initial_stat_set(health, stamina, speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	_handle_character_movement()
	_handle_character_movement_ability()
	_handle_character_attack()

func _handle_character_movement() -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_handle_combat_creature_basic_movement(direction)

func _handle_character_movement_ability() -> void:
	if Input.is_action_just_pressed("dodge"): 
		combat_creature_abilities._use_ability(combat_creature_abilities.ABILITIES[combat_creature_abilities.MOVEMENT][combat_creature_abilities.MOVEMENT_ABILITY_IDS.TESTING_DODGE], {"target": self})
	elif Input.is_action_just_pressed("dash"): 
		combat_creature_abilities._use_ability(combat_creature_abilities.ABILITIES[combat_creature_abilities.MOVEMENT][combat_creature_abilities.MOVEMENT_ABILITY_IDS.TESTING_DASH], {"target": self})

func _handle_character_attack() -> void:
	if Input.is_action_just_pressed("attack_near"):
		pass
	elif Input.is_action_just_pressed("attack_medium"):
		pass
	elif Input.is_action_just_pressed("attack_far"):
		pass

func _init_attach_creature_to_card(card: Node):
	combat_creature_nodes[COMBAT_CARD].node = card
	super._init_combat_card()

func _handle_assign_target(target: Node) -> void:
	combat_creature_nodes[TARGETTING].enemy_target = target
