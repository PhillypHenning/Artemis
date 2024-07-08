extends CombatCreatureBaseClass

@export var health: 	int = 10
@export var stamina: 	int = 10
@export var speed: 		int = 400


var target_dummy_has_taken_damage: bool = false
var heal_timer_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_creature_name = "Target Dummy Card"
	super._ready()
	_init_initial_stat_set(health, stamina, speed)
	_init_heal_to_full_timer()


func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("take_damage"):
		_combat_creature_take_damage(1)
		if !target_dummy_has_taken_damage:
			target_dummy_has_taken_damage = true
			heal_timer_node.start()

	if Input.is_action_just_pressed("use_stamina"):
		combat_creature_current_stamina-=1

	_handle_combat_card()

func _init_heal_to_full_timer() -> void:
	heal_timer_node = Timer.new()
	heal_timer_node.name = "HealTimer"
	heal_timer_node.one_shot = true
	heal_timer_node.wait_time = 10
	combat_creature_timers_node.add_child(heal_timer_node)
	heal_timer_node.connect("timeout", _on_heal_timer_timeout)

func _on_heal_timer_timeout():
	target_dummy_has_taken_damage = false
	combat_creature_current_health = combat_creature_max_health

func _attach_creature_to_card(card: Node):
	combat_creature_card = card
	super._setup_combat_card()

func _handle_targetting(target: Node) -> void:
	combat_creature_target = target
