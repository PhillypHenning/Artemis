class_name CombatCreatureBaseClass

extends CharacterBody2D

var characteristics = preload("res://scripts/combat/creatures/combat_creature_characteristics.gd").new()
var combat_creature_abilities = preload("res://scripts/combat/abilities/abilities_handler.gd").new()
var combat_creature_status_effects = preload("res://scripts/combat/status_effects/status_effect_handler.gd").new()

var combat_creature_brain = preload("res://scripts/combat/ai/goap/agent.gd").new()
var combat_creature_nervous_system = preload("res://scripts/combat/ai/executor/ai_executor.gd").new()

enum {
	TIMERS_GROUP,
	POSITIONS,
	PARENT_NODE,
	COMBAT_CARD,
	TARGETTING,
	MOVEMENT,
	IMAGE,
	DEBUG
}

enum TARGETTING_DETAILS {
	LOS,
	PROXIMITY
}

var combat_creature_nodes = {
	TIMERS_GROUP: {
		"node": null,
		"name": "TimersGroup"
	},
	POSITIONS: {
		"last_known_direction": null,
		"dash_direction": null
	},
	PARENT_NODE: {
		"arena": null
	},
	COMBAT_CARD: {
		"node": null,
		"health_bar": null,
		"stamina_counter": null,
	},
	TARGETTING: {
		TARGETTING_DETAILS.LOS: {
			"los_raycast": null,
			"los_raycast_name": "LosRaycast",
			"los_visualizer": null,
			"los_debug_color": Color.RED,
			"los_debug": false
		},
		TARGETTING_DETAILS.PROXIMITY: {
			"attack_distance_debug": false,
			"proximity_offset": null,
		}
	},
	MOVEMENT: {
		"movement_override": null
	},
	IMAGE: {
		"node": null,
		"size": null
	},
	DEBUG: false
}

var current_plan: Array
var ai_brain_state: bool = false

var collision_layers: Array
var collision_masks: Array

func _ready() -> void:
	_init_containers()

	combat_creature_nodes[PARENT_NODE].arena = find_parent("CombatArena")
	
	# Image
	combat_creature_nodes[IMAGE].node = find_child("Sprite")
	combat_creature_nodes[IMAGE].size = combat_creature_nodes[IMAGE].node.texture.get_size()
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset = ((combat_creature_nodes[IMAGE].size.x + combat_creature_nodes[IMAGE].size.y) / 4)
	
	# Targeting
	_init_assign_target()
	_init_set_mask()
	
	# Signal connections
	_init_attach_creature_card()
	
	# Ability handler setup
	combat_creature_abilities._init_ability_handler(self)
	combat_creature_status_effects._init_ability_handler(self)
	
	# LOS
	_init_create_raycast()


func _init_initial_stat_set(health: float, stamina: int, speed: float) -> void:
	characteristics.current_health = health
	characteristics.max_health = health
	
	characteristics.current_stamina = stamina
	characteristics.max_stamina = stamina
	
	characteristics.starting_speed = speed
	characteristics.current_speed = speed

func _init_attach_creature_card() -> void:
	if combat_creature_nodes[PARENT_NODE].arena != null:
		if characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_player_creature_to_card", _init_attach_creature_to_card)
		else:
			combat_creature_nodes[PARENT_NODE].arena.connect("attach_enemy_creature_to_card", _init_attach_creature_to_card)


func _init_assign_target() -> void:
	if combat_creature_nodes[PARENT_NODE].arena != null:
		if characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1:
			combat_creature_nodes[PARENT_NODE].arena.connect("player_character_target", _handle_assign_target)
		else:
			combat_creature_nodes[PARENT_NODE].arena.connect("enemy_character_target", _handle_assign_target)


func _init_create_raycast() -> void:
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast = RayCast2D.new()
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.name = combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast_name
	
	# Set Default
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(4, true) # Collide with combat terrain
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(5, true) # Collide with CombatCreatures
	
	# Set Specific
	if characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(3, true)
	if characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.NPC_ENEMY:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(1, true)
	
	self.add_child(combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast)


func _init_set_mask() -> void:
	self.collision_layer = 0
	self.collision_mask = 0
	self.set_collision_layer_value(1, false)
	
	# Defaults
	self.set_collision_layer_value(5, true)	# Combat Creature
	collision_layers.append(5)
	self.set_collision_mask_value(2, true) 	# Walls
	collision_masks.append(2)
	self.set_collision_mask_value(4, true)	# Obstacles
	collision_masks.append(4)
	
	if characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1:
		self.set_collision_layer_value(1, true)	# Player
		collision_layers.append(1)
		self.set_collision_mask_value(3, true)	# Enemy
		collision_masks.append(3)
	elif characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.NPC_ENEMY:
		self.set_collision_layer_value(3, true)	# Enemy
		collision_layers.append(3)
		self.set_collision_mask_value(1, true)	# Player
		collision_masks.append(1)

func _init_ai() -> void:
	combat_creature_brain.character_node = self
	combat_creature_brain._ready()
		
	# AI Executor
	combat_creature_nervous_system.character_node = self
	combat_creature_nervous_system.prep_ai_executor()


# PROCESS FUNCTIONS
func _process(delta: float) -> void:
	# TARGETTING
	tracked_delta = delta
	_handle_look_at_target()
	calculate_ideal_combat_range()
	calculate_distance_to_target()

	# GOAP AI
	if ai_brain_state:
		## Prioritize Goals
		combat_creature_brain.determine_goal_priority()
		
		if current_plan.is_empty():
			## Build plan
			current_plan = combat_creature_brain.run_planner()
		else:
			## Execute plan
			current_plan = combat_creature_nervous_system.run_planner(current_plan)

var tracked_delta: float

## MOVEMENT
func handle_combat_creature_basic_movement(end_position: Vector2) -> void:
	var current_position = position
	var direction_to_move = (end_position - current_position).normalized()
	var movement = direction_to_move * characteristics.current_speed * tracked_delta
	if (current_position.distance_to(end_position) <= movement.length()):
		position = end_position  # Snap to the end position
	else:
		velocity = direction_to_move * characteristics.current_speed
		move_and_slide()

func calculate_distance_to_target() -> void:
	if characteristics.enemy_target:
		characteristics.distance_to_target = self.position.distance_to(characteristics.enemy_target.position) - combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset




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
	if characteristics.can_take_damage:
		characteristics.current_health = clamp(characteristics.current_health-amount_of_incoming_damage, 0, characteristics.max_health)
		_handle_update_combat_card()
		combat_creature_status_effects._start_status_effect(combat_creature_status_effects.status_effects[combat_creature_status_effects.DAMAGE_IMMUNITY], {"target": self})
		
		# If I use characteristics.calculate_severity_level do I have access to the current state? 
		#combat_creature_health_characteristics=characteristics.calculate_severity_level(combat_creature_health_characteristics, "health")
		#characteristics.health_severity = CombatCreatureCharacteristics.calculate_severity_level()
		
		
		#combat_creature_brain.goal_conserve_health.goal_priority = (characteristics.health_severity/10)
		
	if characteristics.current_health <= 0:
		characteristics.is_dead = true




# STAMINA
func _use_combat_creature_use_stamina(amount_of_stamina_used: int) -> void:
	characteristics.current_stamina = clamp(characteristics.current_stamina-amount_of_stamina_used, 0, characteristics.max_stamina)
	_handle_update_combat_card()





# COMBAT CARD
func _init_attach_creature_to_card(_card: Node):
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _init_combat_card() -> void:
	var name_node = combat_creature_nodes[COMBAT_CARD].node.find_child("NameLabel")
	name_node.text = characteristics.character_name
	
	combat_creature_nodes[COMBAT_CARD].health_bar = combat_creature_nodes[COMBAT_CARD].node.find_child("HealthBar")
	combat_creature_nodes[COMBAT_CARD].health_bar.max_value = characteristics.max_health
	combat_creature_nodes[COMBAT_CARD].health_bar.value = characteristics.max_health
	
	combat_creature_nodes[COMBAT_CARD].stamina_counter = combat_creature_nodes[COMBAT_CARD].node.find_child("StaminaCounter")
	combat_creature_nodes[COMBAT_CARD].stamina_counter.text = "{current}/{max}".format({"current": characteristics.current_stamina, "max": characteristics.max_stamina})

func _handle_update_combat_card() -> void:
	if combat_creature_nodes[COMBAT_CARD].node:
		combat_creature_nodes[COMBAT_CARD].health_bar.value = characteristics.current_health
		combat_creature_nodes[COMBAT_CARD].stamina_counter.text = "{current}/{max}".format({"current": characteristics.current_stamina, "max": characteristics.max_stamina})





# TARGETTING
func _handle_assign_target(_target: Node) -> void:
	push_error("OVERRIDE THIS IN THE CREATURE CARD")

func _draw() -> void:
	if combat_creature_nodes[DEBUG] and combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_debug:
		draw_line(combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.position, combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position, combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_debug_color, 3.0)
	
	if combat_creature_nodes[DEBUG] and combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].attack_distance_debug:
		
		var m_close = CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		var m_medium = CombatCreatureCharacteristics.PROXIMITY.MELEE_MEDIUM + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		var m_far = CombatCreatureCharacteristics.PROXIMITY.MELEE_FAR + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		var dz = CombatCreatureCharacteristics.PROXIMITY.DEADZONE + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		var r_close = CombatCreatureCharacteristics.PROXIMITY.RANGE_CLOSE + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		var r_far = CombatCreatureCharacteristics.PROXIMITY.RANGE_FAR + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		
		draw_circle(Vector2(0,0), r_far, Color.BLUE)
		draw_circle(Vector2(0,0), r_close, Color.SKY_BLUE)
		draw_circle(Vector2(0,0), dz, Color.DARK_SLATE_GRAY)
		draw_circle(Vector2(0,0), m_far, Color.DARK_RED)
		draw_circle(Vector2(0,0), m_medium, Color.RED)
		draw_circle(Vector2(0,0), m_close, Color.INDIAN_RED)


func _handle_look_at_target() -> void:
	# TARGETTING
	if !characteristics.enemy_target:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position = get_local_mouse_position()
	else:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position = characteristics.enemy_target.global_position - combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.global_position

	# LOS
	characteristics.los_on_target = false
	if combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.is_colliding():
		var target = combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.get_collider() # A CollisionObject2D.
		
		if target == characteristics.enemy_target:
			characteristics.los_on_target = true
		elif target.get_collision_layer_value(4):
			# Raycast is hitting terrain
			pass


func calculate_ideal_combat_range() -> void:
	# Based on the combat_creature_brain.available_actions determine the best combat range
	# If the combat_creature_brain.available_actions array is empty, then the ideal range should be the border of melee_far and range_close
	if len(combat_creature_brain.available_actions) == 0:
		characteristics.current_ideal_range = CombatCreatureCharacteristics.PROXIMITY.DEADZONE



var managed_containers_group_node: Node
var projectiles_group_node: Node
var timers_containers_group_node: Node

var projectiles_nodes: Array
var timers_nodes: Array

func _init_containers() -> void:
	managed_containers_group_node = Node.new()
	managed_containers_group_node.name = "ManagedContainers"
	add_child(managed_containers_group_node)
	
	projectiles_group_node = Node.new()
	projectiles_group_node.name = "Projectiles"
	managed_containers_group_node.add_child(projectiles_group_node)
	
	timers_containers_group_node = Node.new()
	timers_containers_group_node.name = "Timers"
	managed_containers_group_node.add_child(timers_containers_group_node)


func create_group(container_group: String, timer_group_name: String) -> Node:
	var new_group: Node
	var target_container_group: Node
	var target_container_array: Array
	match container_group:
		"Projectiles":
			target_container_group = projectiles_group_node
			target_container_array = projectiles_nodes
			for container in projectiles_nodes:
				if container.name == timer_group_name:
					return container
		"Timers":
			target_container_group = timers_containers_group_node
			target_container_array = timers_nodes
			for container in timers_nodes:
				if container.name == timer_group_name:
					return container
	new_group = Node.new()
	new_group.name = timer_group_name
	target_container_array.append(new_group)
	target_container_group.add_child(new_group)
	return new_group


func create_timer_group(target_timer_group_name: String) -> Node:
	return create_group("Timers", target_timer_group_name)

func create_projectile_group(target_timer_group_name: String) -> Node:
	return create_group("Projectiles", target_timer_group_name)

func add_timer_to_timer_group(target_timer_group_name: String, child_timer: Timer) -> void:
	# Check timer_groups for a matching name
	var target_timer_group: Node = create_timer_group(target_timer_group_name)
	target_timer_group.add_child(child_timer)

func add_projectile_to_projectile_group(target_timer_group_name: String, projectile: Node) -> void:
	# Check timer_groups for a matching name
	var target_projectile_group: Node = create_projectile_group(target_timer_group_name)
	target_projectile_group.add_child(projectile)
