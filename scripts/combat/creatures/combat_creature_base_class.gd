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
var character_has_iframes: bool = false
var character_damage_cooldown: bool = false
var character_damage_lock_timer: Timer
var combat_creature_is_dead: bool = false

# ATTACKING
var marker_close: Marker2D
var marker_medium: Marker2D
var marker_far: Marker2D
var character_is_attacking: bool = false

# MOVEMENT ABILITIES
var character_last_known_direction: Vector2
var character_is_using_movement_ability: bool = false

## DODGING
var character_is_dodging: bool = false

## DASHING
var character_is_dashing: bool = false
var dash_direction: Vector2

# PARENT NODE
var combat_arena_node: Node

# COMBAT CARD
var combat_creature_card: Node
var combat_creature_health_bar: Node
var combat_creature_stamina_counter: Node

# TARGETING
var combat_creature_target: Node

var combat_creature_markers: Node
var combat_creature_target_marker_close: Node
var combat_creature_target_marker_medium: Node
var combat_creature_target_marker_far: Node

# Timers
var combat_creature_timers_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_arena_node = find_parent("CombatArena")
	
	# Targeting
	_create_combat_creature_markers()

	# Timers
	combat_creature_timers_node = Node.new()
	combat_creature_timers_node.name = "Timers"
	add_child(combat_creature_timers_node)
	_combat_creature_setup_damage_lock_timer()
	
	# Signal connections
	if combat_arena_node != null:
		if combat_creature_is_player_creature:
			combat_arena_node.connect("attach_player_creature_to_card", _attach_creature_to_card)
			combat_arena_node.connect("player_character_target", _handle_targetting)
		else:
			combat_arena_node.connect("attach_enemy_creature_to_card", _attach_creature_to_card)
			combat_arena_node.connect("enemy_character_target", _handle_targetting)

func _process(_delta: float) -> void:
	_handle_look_at_target()


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


func _init_add_basic_timers() -> void:
	combat_creature_timers_node = Node.new()
	combat_creature_timers_node.name = "Timers"
	add_child(combat_creature_timers_node)

	
# BASIC MOVEMENT
func _combat_creature_basic_movement(direction: Vector2) -> void:
	character_last_known_direction = direction
	velocity = direction * combat_creature_current_speed
	if character_is_dashing:
		_combat_creature_continue_dash()
	elif character_is_dodging:
		pass
	else:
		move_and_slide()

# ATTACKING
func _combat_creature_attack_at_marker_range(target_range: String) -> void:
	if !character_is_attacking:
		character_is_attacking = true
		$Timers/AttackLockTimer.start()
		match target_range:
			"close":
				print("Attack made at close range")
			"medium":
				print("Attack made at medium range")
			"far":
				print("Attack made at far range")

func _on_attack_lock_timer_timeout():
	character_is_attacking = false

# MOVEMENT ABILITIES
func _combat_creature_handle_movement_ability(ability: String) -> void:
	if !character_is_using_movement_ability:
		character_is_using_movement_ability = true
		match ability:
			"dodge":
				_combat_creature_dodge()
			"dash":
				_combat_creature_dash(character_last_known_direction)

## DASHING
func _combat_creature_dash(direction: Vector2) -> void:
	if !character_is_dashing:
		$Timers/DashLockTimer.start()
		character_is_dashing = true
		dash_direction = direction

func _combat_creature_continue_dash() -> void:
	velocity = dash_direction * (combat_creature_current_speed * 5)
	move_and_slide()

func _on_dash_lock_timer_timeout():
	character_is_dashing = false
	character_is_using_movement_ability = false

## DODGING
func _combat_creature_dodge() -> void:
	if !character_is_dodging:
		$Timers/DodgeLockTimer.start()
		character_is_dodging = true
		character_has_iframes = true

func _on_dodge_lock_timer_timeout():
	character_is_dodging = false
	character_is_using_movement_ability = false
	character_has_iframes = false

# HEALTH
func _combat_creature_take_damage(amount_of_incoming_damage: int):
	if !character_has_iframes and !character_damage_cooldown:
		combat_creature_current_health -= amount_of_incoming_damage
		character_damage_cooldown = true
		character_damage_lock_timer.start()
	if combat_creature_current_health <= 0:
		combat_creature_is_dead = true
		

func _combat_creature_setup_damage_lock_timer() -> void:
	character_damage_lock_timer = Timer.new()
	character_damage_lock_timer.one_shot = true
	character_damage_lock_timer.wait_time = 1
	character_damage_lock_timer.connect("timeout", self._on_damage_lock_timer_timeout)
	$Timers.add_child(character_damage_lock_timer)

func _on_damage_lock_timer_timeout():
	character_damage_cooldown = false

# COMBAT CARD
func _attach_creature_to_card(_card: Node):
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _setup_combat_card() -> void:
	var name_node = combat_creature_card.find_child("NameLabel")
	name_node.text = combat_creature_name
	
	combat_creature_health_bar = combat_creature_card.find_child("HealthBar")
	combat_creature_health_bar.max_value = combat_creature_max_health
	combat_creature_health_bar.value = combat_creature_max_health
	
	combat_creature_stamina_counter = combat_creature_card.find_child("StaminaCounter")
	combat_creature_stamina_counter.text = "{current}/{max}".format({"current": combat_creature_current_stamina, "max": combat_creature_max_stamina})

func _handle_combat_card() -> void:
	if combat_creature_card:
		combat_creature_health_bar.value = combat_creature_current_health
		combat_creature_stamina_counter.text = "{current}/{max}".format({"current": combat_creature_current_stamina, "max": combat_creature_max_stamina})

func _handle_targetting(_target: Node) -> void:
	push_error("OVERRIDE THIS IN THE CREATURE CARD")
	
func _create_combat_creature_markers() -> void:
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

func _handle_look_at_target() -> void:
	if !combat_creature_target:
		combat_creature_markers.look_at(get_global_mouse_position())
	else:
		combat_creature_markers.look_at(combat_creature_target.global_position)
