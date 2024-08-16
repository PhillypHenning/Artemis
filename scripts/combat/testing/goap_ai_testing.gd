extends Node2D

var active_ai: CombatCreatureBaseClass
var inactive_ai: CombatCreatureBaseClass

@onready var current_plan_textbox = $Debug/CurrentPlanText
@onready var goals_textbox = $Debug/GoalsText
@onready var actions_textbox = $Debug/ActionsTextBox
@onready var bot_2_stats = $GoapTestBot2/Bot2Stats

var melee_close_test_attack: AI_Action = load("res://scripts/combat/ai/goap/ability_actions/BasicAttackTest.gd").new()
var ranged_close_test_attack: AI_Action = load("res://scripts/combat/ai/goap/ability_actions/BasicRangedAttackTest.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().current_scene
	active_ai = root_node.find_child("GoapTestBot")
	inactive_ai = root_node.find_child("GoapTestBot2")
	
	active_ai.characteristics.character_type = CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1
	inactive_ai.characteristics.character_type = CombatCreatureCharacteristics.CHARACTER_TYPE.NPC_ENEMY
	active_ai._init_set_mask()
	inactive_ai._init_set_mask()

	# Turn on "active_ai" brain
	active_ai.ai_brain_state = true
	active_ai._init_ai()
	active_ai.characteristics.enemy_target = inactive_ai
	active_ai.combat_creature_nodes[CombatCreatureBaseClass.DEBUG] = true
	active_ai.combat_creature_nodes[CombatCreatureBaseClass.TARGETTING][CombatCreatureBaseClass.TARGETTING_DETAILS.LOS].los_debug = true

	#inactive_ai.ai_brain_state = true
	#inactive_ai._init_ai()
	#inactive_ai.characteristics.enemy_target = active_ai

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handle_current_plan()
	handle_goals()
	handle_state()
	handle_actions()
	active_ai.queue_redraw()


func handle_current_plan() -> void:
	var text_string: String
	text_string = "Current Plan:"
	for action in active_ai.current_plan:
		text_string = "{text_string}\n\tAction: [{name}]".format(
			{
				"text_string": text_string, 
				"name": action.action_name
			}
		)
	current_plan_textbox.text = text_string


func handle_goals() -> void:
	var goals_text: String
	goals_text = "Current Goals:"
	for goal in active_ai.combat_creature_brain.primary_goals:
		goals_text = "{goal_text}\nGoal: [{goal}]\n\tPriority: [{priority}]\n\tCriteria:".format({"goal_text": goals_text, "goal": goal.goal_name, "priority": goal.goal_priority})
		for criteria in goal.goal_criteria:
			goals_text = "{goal_text}\n\t\t[{criteria}] : [{value}]".format({"goal_text": goals_text, "criteria": criteria, "value": goal.goal_criteria[criteria]})
	goals_textbox.text = goals_text


func handle_actions() -> void:
	var static_action_text = "Static Actions:"
	
	for action in active_ai.combat_creature_brain.static_actions:
		static_action_text = "{text}\n{action_print}".format({
			"text": static_action_text,
			"action_print": action.print()
		})
	
	var available_action_text = "\n\nAvailable Actions:"
	
	for action in active_ai.combat_creature_brain.available_actions:
		available_action_text = "{text}\n{action_print}".format({
			"text": available_action_text,
			"action_print": action.print()
		})
	
	actions_textbox.text = static_action_text + available_action_text


func _on_button_pressed():
	active_ai.combat_creature_brain.available_actions.append(melee_close_test_attack.duplicate(true))

func handle_state():
	var text_string: String
	text_string = "Current Health [{0}]".format([inactive_ai.characteristics.current_health])
	bot_2_stats.text = text_string


func _on_button_2_pressed():
	active_ai.combat_creature_brain.available_actions.append(ranged_close_test_attack.duplicate(true))
