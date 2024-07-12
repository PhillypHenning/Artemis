class_name CombatCreatureBaseClass

extends CharacterBody2D

var characteristics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd").new()

var combat_creature_health_characteristics = characteristics.combat_creature_characteristics[characteristics.HEALTH]
var combat_creature_stamina_characteristics = characteristics.combat_creature_characteristics[characteristics.STAMINA]
var combat_creature_movement_characteristics = characteristics.combat_creature_characteristics[characteristics.MOVEMENT]
var combat_creature_dodge_characteristics = characteristics.combat_creature_characteristics[characteristics.DODGING]
var combat_creature_dash_characteristics = characteristics.combat_creature_characteristics[characteristics.DASHING]
var combat_creature_attack_characteristics = characteristics.combat_creature_characteristics[characteristics.ATTACKING]
var combat_creature_details = characteristics.combat_creature_characteristics[characteristics.DETAILS]
var combat_creature_type = characteristics.combat_creature_characteristics[characteristics.TYPE]

enum {
	TIMERS_GROUP,
	POSITIONS,
	PARENT_NODE,
	COMBAT_CARD,
	TARGETTING,
	MARKERS
}

var combat_creature_nodes = {
	TIMERS_GROUP: {
		node = null,
		name = "TimersGroup"
	},
	POSITIONS: {
		last_known_direction = null,
		dash_direction = null
	},
	PARENT_NODE: {
		arena = null
	},
	COMBAT_CARD: {
		node = null,
		health_bar = null,
		stamina_counter = null,
	},
	TARGETTING: {
		enemy_target = null,
		friendly_target = null
	},
	MARKERS: {
		group = {
			node = null,
			name = "MarkersGroup"
		},
		close = null,
		medium = null,
		far = null
	}
}

# TIMERS
var combat_creature_damage_immunity_timer: Timer
var combat_creature_movement_ability_timer: Timer
var combat_creature_dodge_timer: Timer
# MOVE ALL THESE TO THE ABILITY HANDLER


# INITIALIZATION FUNCTIONS
func _ready() -> void:
	combat_creature_nodes[PARENT_NODE].arena = find_parent("CombatArena")
	
	# Targeting
	_init_create_combat_creature_markers()

	# Timers
	_init_create_timers_node_group()
	_init_create_damage_immunity_timer()
	_init_create_movement_ability_timer()
	
	# Signal connections
	_init_attach_creature_card()

func _init_initial_stat_set(health: int, stamina: int, speed: int) -> void:
	combat_creature_health_characteristics.starting_health = health
	combat_creature_health_characteristics.current_health = health
	combat_creature_health_characteristics.max_health = health
	
	combat_creature_stamina_characteristics.starting_stamina = stamina
	combat_creature_stamina_characteristics.current_stamina = stamina
	combat_creature_stamina_characteristics.max_stamina = stamina
	
	combat_creature_movement_characteristics.starting_speed = speed
	combat_creature_movement_characteristics.current_speed = speed
	combat_creature_movement_characteristics.max_speed = speed

func _init_create_combat_creature_markers() -> void:
	combat_creature_nodes[MARKERS].group.node = Node2D.new()
	combat_creature_nodes[MARKERS].group.node.name = combat_creature_nodes[MARKERS].group.name
	add_child(combat_creature_nodes[MARKERS].group.node)
	
	combat_creature_nodes[MARKERS].close = Node2D.new()
	combat_creature_nodes[MARKERS].close.name = "TargetRangeClose"
	combat_creature_nodes[MARKERS].close.position.x = 40
	combat_creature_nodes[MARKERS].group.node.add_child(combat_creature_nodes[MARKERS].close)
	# DEBUG REMOVE START
	var ccr = ColorRect.new()
	ccr.position = combat_creature_nodes[MARKERS].close.position
	ccr.size = Vector2(1,1)
	combat_creature_nodes[MARKERS].close.add_child(ccr)
	# DEBUG REMOVE END
	
	combat_creature_nodes[MARKERS].medium = Node2D.new()
	combat_creature_nodes[MARKERS].medium.name = "TargetRangeMedium"
	combat_creature_nodes[MARKERS].medium.position.x = 70
	combat_creature_nodes[MARKERS].group.node.add_child(combat_creature_nodes[MARKERS].medium)
	# DEBUG REMOVE START
	var ccr2 = ColorRect.new()
	ccr2.position = combat_creature_nodes[MARKERS].medium.position
	ccr2.size = Vector2(1,1)
	combat_creature_nodes[MARKERS].medium.add_child(ccr2)
	# DEBUG REMOVE END
	
	combat_creature_nodes[MARKERS].far = Node2D.new()
	combat_creature_nodes[MARKERS].far.name = "TargetRangeFar"
	combat_creature_nodes[MARKERS].far.position.x = 100
	combat_creature_nodes[MARKERS].group.node.add_child(combat_creature_nodes[MARKERS].far)
	# DEBUG REMOVE START
	var ccr3 = ColorRect.new()
	ccr3.position = combat_creature_nodes[MARKERS].far.position
	ccr3.size = Vector2(1,1)
	combat_creature_nodes[MARKERS].far.add_child(ccr3)
	# DEBUG REMOVE END

func _init_create_timers_node_group() -> void:
	combat_creature_nodes[TIMERS_GROUP].node = Node.new()
	combat_creature_nodes[TIMERS_GROUP].node.name = combat_creature_nodes[TIMERS_GROUP].name
	add_child(combat_creature_nodes[TIMERS_GROUP].node)

func _init_create_damage_immunity_timer() -> void:
	combat_creature_damage_immunity_timer = Timer.new()
	combat_creature_damage_immunity_timer.name = "DamageImmunityTimer"
	combat_creature_damage_immunity_timer.one_shot = true
	combat_creature_damage_immunity_timer.wait_time = combat_creature_health_characteristics.can_take_damage_after_time
	combat_creature_damage_immunity_timer.connect("timeout", self._on_damage_lock_timer_timeout)
	combat_creature_nodes[TIMERS_GROUP].node.add_child(combat_creature_damage_immunity_timer)

func _init_create_movement_ability_timer() -> void:
	combat_creature_movement_ability_timer = Timer.new()
	combat_creature_movement_ability_timer.name = "MovementAbilityTimer"
	combat_creature_movement_ability_timer.one_shot = true
	combat_creature_movement_ability_timer.wait_time = .25
	combat_creature_movement_ability_timer.connect("timeout", self._on_movement_ability_timeout)
	combat_creature_nodes[TIMERS_GROUP].node.add_child(combat_creature_movement_ability_timer)

func _init_attach_creature_card() -> void:
	if combat_creature_nodes[PARENT_NODE].arena != null:
		if combat_creature_type.is_player_character:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_player_creature_to_card", _init_attach_creature_to_card)
			combat_creature_nodes[PARENT_NODE].arena.connect("player_character_target", _init_assign_target)
		else:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_enemy_creature_to_card", _init_attach_creature_to_card)
			combat_creature_nodes[PARENT_NODE].arena.connect("enemy_character_target", _init_assign_target)

# PROCESS FUNCTIONS
func _process(_delta: float) -> void:
	_handle_look_at_target()

## BASIC MOVEMENT
func _handle_combat_creature_basic_movement(direction: Vector2) -> void:
	combat_creature_nodes[POSITIONS].last_known_direction = direction
	velocity = direction * combat_creature_movement_characteristics.current_speed
	if combat_creature_dash_characteristics.is_dashing:
		_handle_combat_creature_continue_dash()
	elif combat_creature_dodge_characteristics.is_dodging:
		pass
	else:
		move_and_slide()





# USE ABILITY
## ATTACKING
func _use_combat_creature_attack_at_marker_range(target_range: String) -> void:
	match target_range:
		"close":
			print("Attack made at close range")
		"medium":
			print("Attack made at medium range")
		"far":
			print("Attack made at far range")






## MOVEMENT ABILITIES
func _use_combat_creature_movement_ability(ability: String) -> void:
	if !combat_creature_movement_characteristics.is_using_movement_ability:
		combat_creature_movement_characteristics.is_using_movement_ability = true
		match ability:
			"dodge":
				_use_combat_creature_dodge()
			"dash":
				_use_combat_creature_dash(combat_creature_nodes[POSITIONS].last_known_direction)

func _on_movement_ability_timeout():
	combat_creature_dash_characteristics.is_dashing = false
	combat_creature_dodge_characteristics.is_dodging = false
	combat_creature_movement_characteristics.is_using_movement_ability = false

### DASHING
func _use_combat_creature_dash(direction: Vector2) -> void:
	if !combat_creature_dash_characteristics.is_dashing:
		combat_creature_movement_ability_timer.start()
		combat_creature_dash_characteristics.is_dashing = true
		combat_creature_nodes[POSITIONS].dash_direction = direction

func _handle_combat_creature_continue_dash() -> void:
	velocity = combat_creature_nodes[POSITIONS].dash_direction * (combat_creature_movement_characteristics.current_speed * 5)
	move_and_slide()


### DODGING
func _use_combat_creature_dodge() -> void:
	if !combat_creature_dodge_characteristics.is_dodging:
		combat_creature_movement_ability_timer.start()
		combat_creature_dodge_characteristics.is_dodging = true
		combat_creature_dodge_characteristics.has_iframes = true






# HEALTH
func _use_combat_creature_take_damage(amount_of_incoming_damage: int) -> void:
	if !combat_creature_dodge_characteristics.has_iframes and combat_creature_health_characteristics.can_take_damage:
		combat_creature_health_characteristics.current_health = clamp(combat_creature_health_characteristics.current_health-amount_of_incoming_damage, 0, combat_creature_health_characteristics.max_health)
		combat_creature_health_characteristics.can_take_damage = false
		combat_creature_damage_immunity_timer.start()
		_handle_update_combat_card()
	if combat_creature_health_characteristics.current_health <= 0:
		combat_creature_health_characteristics.is_dead = true

func _on_damage_lock_timer_timeout():
	combat_creature_health_characteristics.can_take_damage = true





# STAMINA
func _use_combat_creature_use_stamina(amount_of_stamina_used: int) -> void:
	combat_creature_stamina_characteristics.current_stamina = clamp(combat_creature_stamina_characteristics.current_stamina-amount_of_stamina_used, 0, combat_creature_stamina_characteristics.max_stamina)
	_handle_update_combat_card()
	





# COMBAT CARD
func _init_attach_creature_to_card(_card: Node):
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _init_combat_card() -> void:
	var name_node = combat_creature_nodes[COMBAT_CARD].node.find_child("NameLabel")
	name_node.text = combat_creature_details.name
	
	combat_creature_nodes[COMBAT_CARD].health_bar = combat_creature_nodes[COMBAT_CARD].node.find_child("HealthBar")
	combat_creature_nodes[COMBAT_CARD].health_bar.max_value = combat_creature_health_characteristics.max_health
	combat_creature_nodes[COMBAT_CARD].health_bar.value = combat_creature_health_characteristics.max_health
	
	combat_creature_nodes[COMBAT_CARD].stamina_counter = combat_creature_nodes[COMBAT_CARD].node.find_child("StaminaCounter")
	combat_creature_nodes[COMBAT_CARD].stamina_counter.text = "{current}/{max}".format({"current": combat_creature_stamina_characteristics.current_stamina, "max": combat_creature_stamina_characteristics.max_stamina})

func _handle_update_combat_card() -> void:
	if combat_creature_nodes[COMBAT_CARD].node:
		combat_creature_nodes[COMBAT_CARD].health_bar.value = combat_creature_health_characteristics.current_health
		combat_creature_nodes[COMBAT_CARD].stamina_counter.text = "{current}/{max}".format({"current": combat_creature_stamina_characteristics.current_stamina, "max": combat_creature_stamina_characteristics.max_stamina})

# TARGETTING
func _init_assign_target(_target: Node) -> void:
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _handle_look_at_target() -> void:
	if !combat_creature_nodes[TARGETTING].enemy_target:
		combat_creature_nodes[MARKERS].group.node.look_at(get_global_mouse_position())
	else:
		combat_creature_nodes[MARKERS].group.node.look_at(combat_creature_nodes[TARGETTING].enemy_target.global_position)
