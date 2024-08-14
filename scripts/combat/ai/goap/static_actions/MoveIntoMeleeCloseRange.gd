extends AI_Move_to_Action

func _init() -> void:
	super._init()
	action_name = "MoveIntoMeleeCloseRange"
	distance = CombatCreatureCharacteristics.PROXIMITY.MELEE_CLOSE
	preconditions = {}
