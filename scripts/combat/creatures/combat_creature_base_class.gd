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

var combat_creature_proximities = preload("res://scripts/combat/statics/proximity.gd").new()

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

@export var combat_creature_nodes = {
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
		"enemy_target": null,
		"friendly_target": null,
		TARGETTING_DETAILS.LOS: {
			"los_raycast": null,
			"los_raycast_name": "LosRaycast",
			"los_on_target": false,
			"los_visualizer": null,
			"los_debug_color": Color.RED,
			"los_debug": true
		},
		TARGETTING_DETAILS.PROXIMITY: {
			"attack_distance_debug": false,
			"proximity_offset": null,
			"distance_to_target": null,
			"proximity_range": null,
			"close_proximity": 75,
			"medium_proximity": 175,
			"far_proximity": 300,
		}
	},
	MOVEMENT: {
		"movement_override": null
	},
	IMAGE: {
		"node": null,
		"size": null
	},
	DEBUG: true
}

var current_plan: Array

# DEBUG
var debug_state_text = TextEdit
@export var ai_brain_on = true


# INITIALIZATION FUNCTIONS
func _ready() -> void:
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
	
	# GOAP
	if ai_brain_on:
		combat_creature_brain.character_node = self
		combat_creature_brain._ready()
		
		# AI Executor
		combat_creature_nervous_system.character_node = self
	
	# DEBUG
	var root_node = get_tree().current_scene
	debug_state_text = root_node.find_child("DebugStateText")

func _init_initial_stat_set(health: float, stamina: float, speed: float) -> void:
	combat_creature_health_characteristics.starting_health = health
	combat_creature_health_characteristics.current_health = health
	combat_creature_health_characteristics.max_health = health
	
	combat_creature_stamina_characteristics.starting_stamina = stamina
	combat_creature_stamina_characteristics.current_stamina = stamina
	combat_creature_stamina_characteristics.max_stamina = stamina
	
	combat_creature_movement_characteristics.starting_speed = speed
	combat_creature_movement_characteristics.current_speed = speed
	combat_creature_movement_characteristics.max_speed = speed

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
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast = RayCast2D.new()
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.name = combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast_name
	
	# Set Default
	combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(4, true)
	
	# Set Specific
	if combat_creature_type.character_type == characteristics.PLAYER:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(3, true)
	if combat_creature_type.character_type == characteristics.NPC_ENEMY:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.set_collision_mask_value(1, true)
	
	self.add_child(combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast)
	
func _init_set_mask() -> void:
	self.set_collision_mask_value(2, true) 	# Walls
	self.set_collision_mask_value(4, true)	# Obstacles
	if combat_creature_type.character_type == characteristics.PLAYER:
		self.set_collision_layer_value(1, true)	# Player
		self.set_collision_mask_value(3, true)	# Enemy
	if combat_creature_type.character_type == characteristics.NPC_ENEMY:
		self.set_collision_layer_value(1, false)
		self.set_collision_layer_value(3, true)	# Enemy
		self.set_collision_mask_value(1, true)	# Player





# PROCESS FUNCTIONS
func _process(delta: float) -> void:
	# TARGETTING
	_handle_look_at_target()
	
	# GOAP AI
	combat_creature_brain._process(delta)	
	if current_plan.is_empty():
		# Build plan
		combat_creature_brain.run_planner()
		current_plan = combat_creature_brain.current_plan
	else:
		# Execute plan
		combat_creature_brain.current_plan = combat_creature_nervous_system.run_planner()
		current_plan = combat_creature_brain.current_plan
	
	# DEBUG
	_handle_debug()

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
		combat_creature_health_characteristics=characteristics.calculate_severity_level(combat_creature_health_characteristics, "health")
		combat_creature_brain.goal_conserve_health.goal_priority = (combat_creature_health_characteristics.health_severity/10)
		
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
	if combat_creature_nodes[DEBUG] and combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_debug:
		draw_line(combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.position, combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position, combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_debug_color, 3.0)
	
	if combat_creature_nodes[DEBUG] and combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].attack_distance_debug:
		draw_circle(Vector2(0,0), (combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].far_proximity + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset), Color.RED)
		draw_circle(Vector2(0,0), (combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].medium_proximity + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset), Color.BLUE)
		draw_circle(Vector2(0,0), (combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].close_proximity + combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset), Color.GREEN)

func _handle_look_at_target() -> void:
	if !combat_creature_nodes[TARGETTING].enemy_target:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position = get_local_mouse_position()
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].distance_to_target = global_position.distance_to(get_global_mouse_position()) - combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset
		
	else:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.target_position = combat_creature_nodes[TARGETTING].enemy_target.global_position - combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.global_position
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].distance_to_target = global_position.distance_to(combat_creature_nodes[TARGETTING].enemy_target.global_position) - combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_offset

	# LOS
	if combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.is_colliding() and combat_creature_nodes[DEBUG]:
		var target = combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_raycast.get_collider() # A CollisionObject2D.

		if combat_creature_type.character_type == characteristics.PLAYER:
			combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_on_target = target.get_collision_layer_value(3)
		if combat_creature_type.character_type == characteristics.NPC_ENEMY:
			combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_on_target = target.get_collision_layer_value(1)

	# PROXIMITY
	if combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].distance_to_target < combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].close_proximity:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_range = combat_creature_proximities.CLOSE
	elif combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].distance_to_target < combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].medium_proximity:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_range = combat_creature_proximities.MEDIUM
	elif combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].distance_to_target < combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].far_proximity:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_range = combat_creature_proximities.FAR
	else:
		combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_range = combat_creature_proximities.OOMR


func _handle_debug() -> void:
	#var text = "Debug:\n"
	if combat_creature_nodes[DEBUG]:
		if combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_debug:
			queue_redraw()
			#text = "{text}\tlos_on_target: [{los}]".format({"text": text, "los": combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.LOS].los_on_target})
		
		if combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].attack_distance_debug:
			match combat_creature_nodes[TARGETTING][TARGETTING_DETAILS.PROXIMITY].proximity_range:
				combat_creature_proximities.CLOSE:
					print("Target in close range")
				combat_creature_proximities.MEDIUM:
					print("Target in medium range")
				combat_creature_proximities.FAR:
					print("Target in far range")
				combat_creature_proximities.OOMR:
					print("Target out of melee range")
	#debug_state_text.text = text
