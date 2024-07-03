extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	combat_creature_speed = speed
	combat_creature_health = health
	combat_creature_stamina = stamina

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_handle_character_movement()
	_handle_character_attack()

func _handle_character_movement() -> void:
	if !character_is_dodging:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_pressed("dodge"):
			_combat_creature_dodge(direction)
		else: 
			_combat_creature_basic_movement(direction)
	if character_is_dodging:
		_combat_creature_dodge(Vector2(0,0))

func _handle_character_attack() -> void:
	if Input.is_action_just_pressed("attack_near"):
		_combat_creature_attack_at_marker_range("close")
	if Input.is_action_just_pressed("attack_medium"):
		_combat_creature_attack_at_marker_range("medium")
	if Input.is_action_just_pressed("attack_far"):
		_combat_creature_attack_at_marker_range("far")
