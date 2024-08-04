extends Node2D


var player: Node
var enemy: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("PlayerControlledCreature")
	enemy = find_child("TargetDummy")
	
func _process(_delta):
	player.queue_redraw()
	enemy.queue_redraw()


func _on_button_pressed():
	player.combat_creature_nodes[player.DEBUG] = !player.combat_creature_nodes[player.DEBUG]
	player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug = !player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug
	player.combat_creature_nodes[player.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug_color = Color.GREEN


func _on_button_2_pressed():
	enemy.combat_creature_nodes[enemy.DEBUG] = !enemy.combat_creature_nodes[enemy.DEBUG]
	enemy.combat_creature_nodes[enemy.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug = !enemy.combat_creature_nodes[enemy.TARGETTING][player.TARGETTING_DETAILS.LOS].los_debug


func _on_button_3_pressed():
	if !player.characteristics.enemy_target:
		player.characteristics.enemy_target = enemy
	else:
		player.characteristics.enemy_target = null


func _on_button_4_pressed():
	if !enemy.characteristics.enemy_target:
		enemy.characteristics.enemy_target = player
	else:
		enemy.characteristics.enemy_target = null
