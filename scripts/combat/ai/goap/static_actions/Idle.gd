extends AI_Move_to_Action

var antsy_effect_value: int = 10
var action_done: bool = false
var action_wait_time: int = 1
var action_timer: Timer

func _init() -> void:
	action_name = "Idle"
	action_type = ACTION_TYPE.MOVE_TO
	preconditions = {}
	effects = {
		"current_antsy": {
			"apply": antsy_apply,
			"validate": antsy_validate,
			"simulate_only": true
		}
	}
	action_execution = {
		"do_action": {
			"direction": get_direction,
			"distance": get_distance,
			"action_timer": start_action_timer
		},
		"is_complete": is_complete
	}

func antsy_apply(character: CombatCreatureBaseClass) -> CombatCreatureBaseClass:
	character.characteristics.current_antsy = clamp(character.characteristics.current_antsy-antsy_effect_value, 0, character.characteristics.max_antsy)
	return character

func antsy_validate(character: CombatCreatureBaseClass, target_value: float) -> bool:
	antsy_apply(character)
	return character.characteristics.current_antsy == target_value

func get_distance(_character: CombatCreatureBaseClass) -> float:
	return 0

func get_direction(character: CombatCreatureBaseClass) -> Vector2:
	return character.position

func start_action_timer(character: CombatCreatureBaseClass) -> void:
	action_done = false
	var timer = Timer.new()
	timer.wait_time = action_wait_time
	timer.one_shot = true
	timer.autostart = true
	timer.name = "{0}ActionTimer".format([action_name])
	timer.connect("timeout", finish_action_timer.bind(character))
	action_timer = timer
	character.add_child(action_timer)
	action_timer.start()

func finish_action_timer(character: CombatCreatureBaseClass) -> void:
	action_timer.queue_free()
	action_done = true
	antsy_apply(character)

func is_complete(_character: CombatCreatureBaseClass) -> bool:
	return action_done
