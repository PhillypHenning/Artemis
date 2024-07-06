extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400


var target_dummy_has_taken_damage: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_handle_initial_stat_set(health, stamina, speed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("take_damage"):
		_combat_creature_take_damage(1)
		if !target_dummy_has_taken_damage:
			target_dummy_has_taken_damage = true
			$Timers/HealTimer.start()

func _on_heal_timer_timeout():
	target_dummy_has_taken_damage = false
	combat_creature_current_health = combat_creature_max_health
