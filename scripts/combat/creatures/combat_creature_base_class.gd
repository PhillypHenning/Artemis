class_name CombatCreatureBaseClass

extends CharacterBody2D

var combat_creature_name: String = "BaseClassChangeThis"
var combat_creature_is_player_creature: bool = false

var combat_creature_initial_health: int = 0:
	set(value):
		combat_creature_initial_health = value
	get:
		return combat_creature_initial_health
var combat_creature_max_health: int = 0:
	set(value):
		combat_creature_max_health = value
	get:
		return combat_creature_max_health
var combat_creature_current_health: int = 0:
	set(value):
		combat_creature_current_health = value
	get:
		return combat_creature_current_health

var combat_creature_initial_stamina: int = 0:
	set(value):
		combat_creature_initial_stamina = value
	get:
		return combat_creature_initial_stamina
var combat_creature_max_stamina: int = 0:
	set(value):
		combat_creature_max_stamina = value
	get:
		return combat_creature_max_stamina
var combat_creature_current_stamina: int = 0:
	set(value):
		combat_creature_current_stamina = value
	get:
		return combat_creature_current_stamina

var combat_creature_initial_speed: int = 0:
	set(value):
		combat_creature_initial_speed = value
	get:
		return combat_creature_initial_speed
var combat_creature_max_speed: int = 0:
	set(value):
		combat_creature_max_speed = value
	get:
		return combat_creature_max_speed
var combat_creature_current_speed: int = 0:
	set(value):
		combat_creature_current_speed = value
	get:
		return combat_creature_current_speed

# HEALTH
var combat_creature_has_iframes: bool = false
var combat_creature_damage_cooldown: bool = false
var combat_creature_damage_immunity_timer: Timer
var combat_creature_is_dead: bool = false
var combat_creature_damage_immunity_time = 1

# ATTACKING
var combat_creature_is_attacking: bool = false

# MOVEMENT ABILITIES
var combat_creature_last_known_direction: Vector2
var combat_creature_is_using_movement_ability: bool = false
var combat_creature_movement_ability_timer: Node

## DODGING
var combat_creature_is_dodging: bool = false
var combat_creature_dodge_timer: Node

## DASHING
var combat_creature_is_dashing: bool = false
var combat_creature_dash_direction: Vector2

# PARENT NODE
var combat_arena_node: Node

# COMBAT CARD
var combat_creature_card: Node
var combat_creature_card_health_bar: Node
var combat_creature_card_stamina_counter: Node

# TARGETING
var combat_creature_target: Node

var combat_creature_markers: Node
var combat_creature_target_marker_close: Node
var combat_creature_target_marker_medium: Node
var combat_creature_target_marker_far: Node

# Timers
var combat_creature_timers_node_group: Node


# INITIALIZATION FUNCTIONS
func _ready() -> void:
	combat_arena_node = find_parent("CombatArena")
	
	# Targeting
	_init_create_combat_creature_markers()

	# Timers
	_init_create_timers_node_group()
	_init_create_damage_immunity_timer()
	_init_create_movement_ability_timer()
	
	# Signal connections
	_init_attach_creature_card()

func _init_initial_stat_set(health: int, stamina: int, speed: int) -> void:
	combat_creature_initial_health = health
	combat_creature_max_health = health
	combat_creature_current_health = health
	
	combat_creature_initial_stamina = stamina
	combat_creature_max_stamina = stamina
	combat_creature_current_stamina = stamina
	
	combat_creature_initial_speed = speed
	combat_creature_max_speed = speed
	combat_creature_current_speed = speed

func _init_create_combat_creature_markers() -> void:
	combat_creature_markers = Node2D.new()
	combat_creature_markers.name = "TargetMarkers"
	add_child(combat_creature_markers)
	
	combat_creature_target_marker_close = Node2D.new()
	combat_creature_target_marker_close.name = "TargetRangeClose"
	combat_creature_target_marker_close.position.x = 40
	combat_creature_markers.add_child(combat_creature_target_marker_close)
	# DEBUG REMOVE START
	var ccr = ColorRect.new()
	ccr.position = combat_creature_target_marker_close.position
	ccr.size = Vector2(1,1)
	combat_creature_target_marker_close.add_child(ccr)
	# DEBUG REMOVE END
	
	combat_creature_target_marker_medium = Node2D.new()
	combat_creature_target_marker_medium.name = "TargetRangeMedium"
	combat_creature_target_marker_medium.position.x = 70
	combat_creature_markers.add_child(combat_creature_target_marker_medium)
	# DEBUG REMOVE START
	var ccr2 = ColorRect.new()
	ccr2.position = combat_creature_target_marker_medium.position
	ccr2.size = Vector2(1,1)
	combat_creature_target_marker_medium.add_child(ccr2)
	# DEBUG REMOVE END
	
	combat_creature_target_marker_far = Node2D.new()
	combat_creature_target_marker_far.name = "TargetRangeFar"
	combat_creature_target_marker_far.position.x = 100
	combat_creature_markers.add_child(combat_creature_target_marker_far)
	# DEBUG REMOVE START
	var ccr3 = ColorRect.new()
	ccr3.position = combat_creature_target_marker_far.position
	ccr3.size = Vector2(1,1)
	combat_creature_target_marker_far.add_child(ccr3)
	# DEBUG REMOVE END

func _init_create_timers_node_group() -> void:
	combat_creature_timers_node_group = Node.new()
	combat_creature_timers_node_group.name = "Timers"
	add_child(combat_creature_timers_node_group)

func _init_create_damage_immunity_timer() -> void:
	combat_creature_damage_immunity_timer = Timer.new()
	combat_creature_damage_immunity_timer.name = "DamageImmunityTimer"
	combat_creature_damage_immunity_timer.one_shot = true
	combat_creature_damage_immunity_timer.wait_time = combat_creature_damage_immunity_time
	combat_creature_damage_immunity_timer.connect("timeout", self._on_damage_lock_timer_timeout)
	combat_creature_timers_node_group.add_child(combat_creature_damage_immunity_timer)

func _init_create_movement_ability_timer() -> void:
	combat_creature_movement_ability_timer = Timer.new()
	combat_creature_movement_ability_timer.name = "MovementAbilityTimer"
	combat_creature_movement_ability_timer.one_shot = true
	combat_creature_movement_ability_timer.wait_time = .25
	combat_creature_movement_ability_timer.connect("timeout", self._on_movement_ability_timeout)
	combat_creature_timers_node_group.add_child(combat_creature_movement_ability_timer)

func _init_attach_creature_card() -> void:
	if combat_arena_node != null:
		if combat_creature_is_player_creature:
			combat_arena_node.connect("attach_player_creature_to_card", _init_attach_creature_to_card)
			combat_arena_node.connect("player_character_target", _init_assign_target)
		else:
			combat_arena_node.connect("attach_enemy_creature_to_card", _init_attach_creature_to_card)
			combat_arena_node.connect("enemy_character_target", _init_assign_target)

# PROCESS FUNCTIONS
func _process(_delta: float) -> void:
	_handle_look_at_target()

## BASIC MOVEMENT
func _handle_combat_creature_basic_movement(direction: Vector2) -> void:
	combat_creature_last_known_direction = direction
	velocity = direction * combat_creature_current_speed
	if combat_creature_is_dashing:
		_handle_combat_creature_continue_dash()
	elif combat_creature_is_dodging:
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
	if !combat_creature_is_using_movement_ability:
		combat_creature_is_using_movement_ability = true
		match ability:
			"dodge":
				_use_combat_creature_dodge()
			"dash":
				_use_combat_creature_dash(combat_creature_last_known_direction)

func _on_movement_ability_timeout():
	combat_creature_is_dashing = false
	combat_creature_is_dodging = false
	combat_creature_is_using_movement_ability = false

### DASHING
func _use_combat_creature_dash(direction: Vector2) -> void:
	if !combat_creature_is_dashing:
		combat_creature_movement_ability_timer.start()
		combat_creature_is_dashing = true
		combat_creature_dash_direction = direction

func _handle_combat_creature_continue_dash() -> void:
	velocity = combat_creature_dash_direction * (combat_creature_current_speed * 5)
	move_and_slide()


### DODGING
func _use_combat_creature_dodge() -> void:
	if !combat_creature_is_dodging:
		combat_creature_movement_ability_timer.start()
		combat_creature_is_dodging = true
		combat_creature_has_iframes = true






# HEALTH
func _use_combat_creature_take_damage(amount_of_incoming_damage: int) -> void:
	if !combat_creature_has_iframes and !combat_creature_damage_cooldown:
		combat_creature_current_health = clamp(combat_creature_current_health-amount_of_incoming_damage, 0, combat_creature_max_health)
		combat_creature_damage_cooldown = true
		combat_creature_damage_immunity_timer.start()
		_handle_update_combat_card()
	if combat_creature_current_health <= 0:
		combat_creature_is_dead = true

func _on_damage_lock_timer_timeout():
	combat_creature_damage_cooldown = false





# STAMINA
func _use_combat_creature_use_stamina(amount_of_stamina_used: int) -> void:
	combat_creature_current_stamina = clamp(combat_creature_current_stamina-amount_of_stamina_used, 0, combat_creature_max_stamina)
	_handle_update_combat_card()
	





# COMBAT CARD
func _init_attach_creature_to_card(_card: Node):
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _init_combat_card() -> void:
	var name_node = combat_creature_card.find_child("NameLabel")
	name_node.text = combat_creature_name
	
	combat_creature_card_health_bar = combat_creature_card.find_child("HealthBar")
	combat_creature_card_health_bar.max_value = combat_creature_max_health
	combat_creature_card_health_bar.value = combat_creature_max_health
	
	combat_creature_card_stamina_counter = combat_creature_card.find_child("StaminaCounter")
	combat_creature_card_stamina_counter.text = "{current}/{max}".format({"current": combat_creature_current_stamina, "max": combat_creature_max_stamina})

func _handle_update_combat_card() -> void:
	if combat_creature_card:
		combat_creature_card_health_bar.value = combat_creature_current_health
		combat_creature_card_stamina_counter.text = "{current}/{max}".format({"current": combat_creature_current_stamina, "max": combat_creature_max_stamina})

# TARGETTING
func _init_assign_target(_target: Node) -> void:
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _handle_look_at_target() -> void:
	if !combat_creature_target:
		combat_creature_markers.look_at(get_global_mouse_position())
	else:
		combat_creature_markers.look_at(combat_creature_target.global_position)
