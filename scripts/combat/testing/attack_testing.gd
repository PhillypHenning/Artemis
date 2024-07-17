extends Node2D


var player: Node
var enemy: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("PlayerControlledCreature")
	enemy = find_child("TargetDummy")
	player.combat_creature_nodes[player.TARGETTING].enemy_target = enemy
	enemy.combat_creature_nodes[enemy.TARGETTING].enemy_target = player
	
func _process(_delta):
	player.queue_redraw()
	enemy.queue_redraw()


func _on_button_pressed():
	player.combat_creature_nodes[player.DEBUG] = !player.combat_creature_nodes[player.DEBUG]
	player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.PROXIMITY].attack_distance_debug = !player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.PROXIMITY].attack_distance_debug
	player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug_color = Color.GREEN


func _on_button_2_pressed():
	enemy.combat_creature_nodes[enemy.DEBUG] = !enemy.combat_creature_nodes[enemy.DEBUG]
	enemy.combat_creature_nodes[enemy.TARGETTING][enemy.TARGETTING_DETAILS.PROXIMITY].attack_distance_debug = !enemy.combat_creature_nodes[enemy.TARGETTING][enemy.TARGETTING_DETAILS.PROXIMITY].attack_distance_debug


func _on_button_3_pressed():
	if !player.combat_creature_nodes[player.TARGETTING].enemy_target:
		player.combat_creature_nodes[player.TARGETTING].enemy_target = enemy
	else:
		player.combat_creature_nodes[player.TARGETTING].enemy_target = null


func _on_button_4_pressed():
	if !enemy.combat_creature_nodes[enemy.TARGETTING].enemy_target:
		enemy.combat_creature_nodes[enemy.TARGETTING].enemy_target = player
	else:
		enemy.combat_creature_nodes[enemy.TARGETTING].enemy_target = null
