extends AI_Move_to_Action

func _init() -> void:
	super._init()
	action_name = "MoveIntoRangedCloseRange"
	distance = CombatCreatureCharacteristics.PROXIMITY.RANGE_CLOSE
	preconditions = {}
