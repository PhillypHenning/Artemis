class_name CombatCreatureBaseClass

extends CharacterBody2D

var characteristics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd").new()

var combat_creature_health_characteristics = characteristics.combat_creature_characteristics[characteristics.HEALTH]
var combat_creature_stamina_characteristics = characteristics.combat_creature_characteristics[characteristics.STAMINA]
var combat_creature_movement_characteristics = characteristics.combat_creature_characteristics[characteristics.MOVEMENT]
var combat_creature_attack_characteristics = characteristics.combat_creature_characteristics[characteristics.ATTACKING]
var combat_creature_details = characteristics.combat_creature_characteristics[characteristics.DETAILS]
var combat_creature_type = characteristics.combat_creature_characteristics[characteristics.TYPE]

var combat_creature_abilities = preload("res://scripts/combat/abilities/abilities_handler.gd").new()
var combat_creature_status_effects = preload("res://scripts/combat/status_effects/status_effect_handler.gd").new()

enum {
	TIMERS_GROUP,
	POSITIONS,
	PARENT_NODE,
	COMBAT_CARD,
	TARGETTING,
	MARKERS,
	MOVEMENT,
	DEBUG
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
		friendly_target = null,
		los_raycast = null,
		los_raycast_name = "LosRaycast",
		line_of_sight = false,
		los_visualizer = null
	},
	MARKERS: {
		group = {
			node = null,
			name = "MarkersGroup"
		},
		close = null,
		medium = null,
		far = null
	},
	MOVEMENT: {
		movement_override = null
	},
	DEBUG: false
}

# INITIALIZATION FUNCTIONS
func _ready() -> void:
	combat_creature_nodes[PARENT_NODE].arena = find_parent("CombatArena")
	
	# Targeting
	_init_create_combat_creature_markers()
	_init_assign_target()
	_init_set_mask()
	
	# Signal connections
	_init_attach_creature_card()
	
	# Ability handler setup
	combat_creature_abilities._init_ability_handler(self)
	combat_creature_status_effects._init_ability_handler(self)
	
	_init_create_raycast()

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

func _init_attach_creature_card() -> void:
	if combat_creature_nodes[PARENT_NODE].arena != null:
		if combat_creature_type.character_type == characteristics.PLAYER:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_player_creature_to_card", _init_attach_creature_to_card)
		else:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_enemy_creature_to_card", _init_attach_creature_to_card)

func _init_assign_target() -> void:
	if combat_creature_nodes[PARENT_NODE].arena != null:
		if combat_creature_type.character_type == characteristics.PLAYER:
			combat_creature_nodes[PARENT_NODE].arena.connect("player_character_target", _handle_assign_target)
		else:
			combat_creature_nodes[PARENT_NODE].arena.connect("enemy_character_target", _handle_assign_target)

func _init_create_raycast() -> void:
	combat_creature_nodes[TARGETTING].los_raycast = RayCast2D.new()
	combat_creature_nodes[TARGETTING].los_raycast.name = combat_creature_nodes[TARGETTING].los_raycast_name
	combat_creature_nodes[TARGETTING].los_raycast.set_collision_mask(4)
	self.add_child(combat_creature_nodes[TARGETTING].los_raycast)
	
func _init_set_mask() -> void:
	if combat_creature_type.character_type == characteristics.PLAYER:
		self.set_collision_layer_value(1, true)
		self.set_collision_mask_value(3, true)
	if combat_creature_type.character_type == characteristics.NPC_ENEMY:
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(3, true)
		self.set_collision_mask_value(1, true)


# PROCESS FUNCTIONS
func _process(_delta: float) -> void:
	_handle_look_at_target()
	if combat_creature_nodes[DEBUG]:
		queue_redraw()





## BASIC MOVEMENT
func _handle_combat_creature_basic_movement(direction: Vector2) -> void:
	if !combat_creature_nodes[MOVEMENT].movement_override:
		combat_creature_nodes[POSITIONS].last_known_direction = direction
		velocity = direction * combat_creature_movement_characteristics.current_speed
		move_and_slide()
	else:
		combat_creature_nodes[MOVEMENT].movement_override.call({"target": self})





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





# HEALTH
func _use_combat_creature_take_damage(amount_of_incoming_damage: int) -> void:
	if combat_creature_health_characteristics.can_take_damage:
		combat_creature_health_characteristics.current_health = clamp(combat_creature_health_characteristics.current_health-amount_of_incoming_damage, 0, combat_creature_health_characteristics.max_health)
		_handle_update_combat_card()
		combat_creature_status_effects._start_status_effect(combat_creature_status_effects.status_effects[combat_creature_status_effects.DAMAGE_IMMUNITY], {"target": self})
		
	if combat_creature_health_characteristics.current_health <= 0:
		combat_creature_health_characteristics.is_dead = true

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
func _handle_assign_target(_target: Node) -> void:
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _draw() -> void:
	if combat_creature_nodes[DEBUG]:
		draw_line(combat_creature_nodes[TARGETTING].los_raycast.position, combat_creature_nodes[TARGETTING].los_raycast.target_position, Color.RED, 3.0)

func _handle_look_at_target() -> void:
	
	if !combat_creature_nodes[TARGETTING].enemy_target:
		var mouse_pos = get_global_mouse_position()
		combat_creature_nodes[MARKERS].group.node.look_at(mouse_pos)
		combat_creature_nodes[TARGETTING].los_raycast.target_position = get_local_mouse_position()

	else:
		combat_creature_nodes[MARKERS].group.node.look_at(combat_creature_nodes[TARGETTING].enemy_target.global_position)
		combat_creature_nodes[TARGETTING].los_raycast.target_position = combat_creature_nodes[TARGETTING].enemy_target.global_position

	if combat_creature_nodes[TARGETTING].los_raycast.is_colliding() and combat_creature_nodes[DEBUG]:
		var target = combat_creature_nodes[TARGETTING].los_raycast.get_collider() # A CollisionObject2D.
		var shape_id = combat_creature_nodes[TARGETTING].los_raycast.get_collider_shape() # The shape index in the collider.
		var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		var shape = target.shape_owner_get_owner(owner_id)
		
		print("Collision detected by [{type}] target: {target}, shape_id: {shape_id}, owner_id: {owner_id}, shape: {shape},". format({"type": combat_creature_type.character_type, "target": target, "shape_id": shape_id, "owner_id": owner_id, "shape": shape}))
