extends Node2D


var player: Node
var enemy: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_child("PlayerControlledCreature")
	enemy = find_child("TargetDummy")


func _on_button_pressed():
	player.combat_creature_nodes[player.DEBUG] = !player.combat_creature_nodes[player.DEBUG]


func _on_button_2_pressed():
	enemy.combat_creature_nodes[enemy.DEBUG] = !enemy.combat_creature_nodes[enemy.DEBUG]
