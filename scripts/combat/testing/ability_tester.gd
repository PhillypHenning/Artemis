extends Node

var ability_handler = preload("res://scripts/combat/abilities/abilities_handler.gd").new()

var reported_health = 0

@export var amount_healed: int = 3
@onready var target_dummy = $TargetDummy
@onready var bullet_spawn_1 = $BulletSpawnPointGroup/BulletSpawn1
@onready var bullet_spawn_2 = $BulletSpawnPointGroup/BulletSpawn2
@onready var bullet_spawn_3 = $BulletSpawnPointGroup/BulletSpawn3
@onready var selected_bullet_spawn_visualizer = $BulletSpawnPointGroup/SelectedBulletSpawnVisualizer
@export var Bullet: PackedScene = preload("res://scenes/combat/projectiles/test_projectile.tscn")

var debug_range = CombatCreatureCharacteristics.PROXIMITY
var selected_bullet_spawn = null

func _ready() -> void:
	_on_target_dummy_reset_pressed()
	_on_set_bullet_spawn_1_pressed()


func _process(_delta) -> void:
	selected_bullet_spawn.look_at(target_dummy.global_position)
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot():
	var bullet = Bullet.instantiate()
	add_child(bullet)
	bullet.transform = selected_bullet_spawn.global_transform


func _on_target_dummy_reset_pressed():
	target_dummy.characteristics.current_health = 10
	target_dummy.characteristics.max_health = 10


#func _on_heal_over_time_ability_button_pressed():
	#print("Heal Over Time Ability Test Started")
	#var ability = healing_abilities[ability_handler.HEALING_ABILITY_IDS.HEAL_TO_FULL_AFTER_TIME]
	#var parameters: Dictionary
	#parameters.target = target_dummy
	#parameters.wait_time = 10
	#parameters.amount = amount_healed
	#ability_handler._use_ability(ability, parameters)


#func _on_close_melee_attack_ability_button_pressed():
	#print("Close Melee Attack Test Started")
	#var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_CLOSE_MELEE]
	#var parameters: Dictionary
	#parameters.target = target_dummy
	#parameters.target.combat_creature_nodes[target_dummy.TARGETTING][target_dummy.TARGETTING_DETAILS.PROXIMITY].proximity_range = debug_range
	#parameters.amount = 1
	#ability_handler._use_ability(ability, parameters)
#
#
#func _on_medium_melee_attack_ability_button_pressed():
	#print("Medium Melee Attack Test Started")
	#var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_MEDIUM_MELEE]
	#var parameters: Dictionary
	#parameters.target = target_dummy
	#parameters.target.combat_creature_nodes[target_dummy.TARGETTING][target_dummy.TARGETTING_DETAILS.PROXIMITY].proximity_range = debug_range
	#parameters.amount = 1
	#ability_handler._use_ability(ability, parameters)
#
#
#func _on_far_melee_attack_ability_button_pressed():
	#print("Far Melee Attack Test Started")
	#var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_FAR_MELEE]
	#var parameters: Dictionary
	#parameters.target = target_dummy
	#parameters.target.combat_creature_nodes[target_dummy.TARGETTING][target_dummy.TARGETTING_DETAILS.PROXIMITY].proximity_range = debug_range
	#parameters.amount = 1
	#ability_handler._use_ability(ability, parameters)
#
#
#func _on_multi_proxy_melee_attack_ability_button_pressed():
	#print("Far Melee Attack Test Started")
	#var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_MULTI_PROXY_MELEE]
	#var parameters: Dictionary
	#parameters.target = target_dummy
	#parameters.target.combat_creature_nodes[target_dummy.TARGETTING][target_dummy.TARGETTING_DETAILS.PROXIMITY].proximity_range = debug_range
	#parameters.amount = 1
	#ability_handler._use_ability(ability, parameters)


func _on_set_close_pressed():
	debug_range = CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE
	
	
func _on_set_medium_pressed():
	debug_range = CombatCreatureCharacteristics.PROXIMITY.MELEE_MEDIUM


func _on_set_far_pressed():
	debug_range = CombatCreatureCharacteristics.PROXIMITY.MELEE_FAR


func _on_set_oomr_pressed():
	debug_range = CombatCreatureCharacteristics.PROXIMITY.RANGE_CLOSE


func _on_set_bullet_spawn_1_pressed():
	selected_bullet_spawn = bullet_spawn_1
	selected_bullet_spawn_visualizer.position = selected_bullet_spawn.position


func _on_set_bullet_spawn_2_pressed():
	selected_bullet_spawn = bullet_spawn_2
	selected_bullet_spawn_visualizer.position = selected_bullet_spawn.position


func _on_set_bullet_spawn_3_pressed():
	selected_bullet_spawn = bullet_spawn_3
	selected_bullet_spawn_visualizer.position = selected_bullet_spawn.position

var test_bullet: PackedScene = preload("res://scenes/combat/projectiles/test_projectile.tscn")
func _on_spawn_bullet_button_pressed():
	#var ability = offensive_abilities[ability_handler.OFFENSIVE_ABILITY_TEST_IDS.TESTING_PROJECTILES]
	#var parameters: Dictionary
	var spawned_bullet = test_bullet.instantiate()
	
	#spawned_bullet.transform = parameters.shoot_at_position
	#spawned_bullet.damage_amount = parameters.amount
	#spawned_bullet.speed = parameters.speed
	
	character.add_projectile_to_projectile_group("BasicAttack", spawned_bullet)
	
	spawned_bullet.transform = bullet_spawn_point
	spawned_bullet.damage_amount = damage_amount
	spawned_bullet.speed = bullet_speed
	
	parameters.shoot_at_position = selected_bullet_spawn.global_transform
	ability_handler._use_ability(ability, parameters)
