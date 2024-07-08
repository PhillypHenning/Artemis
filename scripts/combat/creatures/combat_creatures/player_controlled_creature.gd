extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_creature_is_player_creature = true
	combat_creature_name = "Player Controlled Creature"
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
	_combat_creature_basic_movement(direction)

func _handle_character_movement_ability() -> void:
	if Input.is_action_just_pressed("dodge"): _combat_creature_handle_movement_ability("dodge")
	elif Input.is_action_just_pressed("dash"): _combat_creature_handle_movement_ability("dash")

func _handle_character_attack() -> void:
	if Input.is_action_just_pressed("attack_near"):
		_combat_creature_attack_at_marker_range("close")
	if Input.is_action_just_pressed("attack_medium"):
		_combat_creature_attack_at_marker_range("medium")
	if Input.is_action_just_pressed("attack_far"):
		_combat_creature_attack_at_marker_range("far")

func _attach_creature_to_card(card: Node):
	combat_creature_card = card
	super._setup_combat_card()

func _handle_targetting(target: Node) -> void:
	combat_creature_target = target
