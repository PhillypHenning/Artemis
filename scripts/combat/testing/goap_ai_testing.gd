extends Node2D

var active_ai: CombatCreatureBaseClass
var inactive_ai: CombatCreatureBaseClass

@onready var current_plan_textbox = $Debug/CurrentPlanText
@onready var goals_textbox = $Debug/GoalsText
@onready var debug_state_textbox = $Debug/DebugStateText

# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().current_scene
	active_ai = root_node.find_child("GoapTestBot")
	inactive_ai = root_node.find_child("GoapTestBot2")

	# Turn on "active_ai" brain
	active_ai.ai_brain_state = true
	active_ai._init_ai()
	active_ai.characteristics.enemy_target = inactive_ai

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_current_plan()
	handle_goals()
	handle_state()


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


func handle_state() -> void:
	var text = "State:\n"
	text = "{text}\tlos_on_target: [{los}]
\tcurrent_antsy: [{antsy}]
\tcurrent_ideal_range: [{ideal_range}]
\tdistance_from_target: [{distance_from_target}]".format(
		{
			"text": text, 
			"los": active_ai.characteristics.los_on_target,
			"antsy": active_ai.characteristics.current_antsy,
			"ideal_range": active_ai.characteristics.current_ideal_range,
			"distance_from_target": '%.2f' % active_ai.characteristics.distance_from_target,
		}
	)
	debug_state_textbox.text = text
