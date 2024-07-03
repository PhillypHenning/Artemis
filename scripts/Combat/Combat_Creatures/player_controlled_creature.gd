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
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_move_combat_creature(_delta, direction)
