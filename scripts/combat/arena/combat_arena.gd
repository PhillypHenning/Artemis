extends Node2D

@onready var player_spawn_point = $CreatureSpawnPoints/PlayerSpawnPoint
@onready var target_dummy_spawn_point = $CreatureSpawnPoints/TargetDummySpawnPoint
@onready var card_spawn_1 = $CreatureCards/CardSpawn1
@onready var card_spawn_2 = $CreatureCards/CardSpawn2
@onready var prepped_action_1 = $ActionStack/VBoxContainer/MarginContainer2/PreppedAction1
@onready var prepped_action_2 = $ActionStack/VBoxContainer/MarginContainer3/PreppedAction2
@onready var prepped_action_3 = $ActionStack/VBoxContainer/MarginContainer4/PreppedAction3

var action_stack: Dictionary = {
	"Action_1": null,
	"Action_2": null,
	"Action_3": null
}

var player_creature_scene = load("res://scenes/combat/player_controlled_creature.tscn")
var target_dummy_creature_scene = load("res://scenes/combat/target_dummy.tscn")
var creature_card_scene = load("res://scenes/UI/combat_creature_card.tscn")

const Utils = preload("res://scripts/utils/utils.gd")
var utils = Utils.new()

signal attach_player_creature_to_card(Node)
signal attach_enemy_creature_to_card(Node)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(utils.spawn_packedscene_at_spawn_point(player_creature_scene, player_spawn_point.position, "PlayerCreature"))
	add_child(utils.spawn_packedscene_at_spawn_point(target_dummy_creature_scene, target_dummy_spawn_point.position, "TargetDummy"))
	var pcc = utils.spawn_packedscene_at_spawn_point(creature_card_scene, card_spawn_1.position, "PlayerCreatureCard")
	add_child(pcc)
	var tdc = utils.spawn_packedscene_at_spawn_point(creature_card_scene, card_spawn_2.position, "TargetDummyCard")
	add_child(tdc)
	
	attach_player_creature_to_card.emit(pcc)
	attach_enemy_creature_to_card.emit(tdc)

func _process(_delta) -> void:
	_handle_stack()

func _handle_stack() -> void:
	if action_stack["Action_1"]:
		prepped_action_1.text = action_stack["Action_1"]
	else:
		prepped_action_1.text = ""
	if action_stack["Action_2"]:
		prepped_action_2.text = action_stack["Action_2"]
	else:
		prepped_action_2.text = ""
	if action_stack["Action_3"]:
		prepped_action_3.text = action_stack["Action_3"]
	else:
		prepped_action_3.text = ""

func _add_to_stack(action: String):
	if !action_stack["Action_1"]:
		action_stack["Action_1"] = action
		return
	if !action_stack["Action_2"]:
		action_stack["Action_2"] = action
		return
	if !action_stack["Action_3"]:
		action_stack["Action_3"] = action
		return
	
	action_stack["Action_3"] = action_stack["Action_2"]
	action_stack["Action_2"] = action_stack["Action_1"]
	action_stack["Action_1"] = action

func _on_attack_button_pressed():
	print("Attack Button Pressed")
	_add_to_stack("Attack")


func _on_dodge_button_pressed():
	print("Dodge Button Pressed")
	_add_to_stack("Dodge")


func _on_dash_button_pressed():
	print("Dash Button Pressed")
	_add_to_stack("Dash")
