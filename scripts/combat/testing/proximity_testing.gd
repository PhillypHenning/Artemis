extends Node2D

var target: CombatCreatureBaseClass

# Called when the node enters the scene tree for the first time.
func _ready():
	target = find_child("TargetDummy")
	target.combat_creature_nodes[CombatCreatureBaseClass.DEBUG] = true
	target.combat_creature_nodes[CombatCreatureBaseClass.TARGETTING][CombatCreatureBaseClass.TARGETTING_DETAILS.PROXIMITY].attack_distance_debug = true

func _process(delta):
	target.queue_redraw()
