extends AI_Goal

var AIUtils = preload("res://scripts/combat/ai/utils.gd").new()

func _init(character: CombatCreatureBaseClass):
	self.goal_name = "DoTheAntsyShuffle"
	self.goal_criteria = { 
		"current_antsy": float(0)
	}
	self.goal_priority = 0
	self.cc_character = character
	self.goal_timer_interval = 1
	
	var timer = Timer.new()
	timer.name = self.goal_name + "Timer"
	timer.wait_time = self.goal_timer_interval
	timer.one_shot = false
	timer.autostart = true

	timer.connect("timeout", interval_increase)
	character.call_deferred("add_child", timer)

func calculate_priority() -> float:
	self.goal_priority = self.cc_character.characteristics.current_antsy
	return self.goal_priority

func interval_increase() -> void:
	if self.cc_character:
		var new_antsy = clamp((self.cc_character.characteristics.current_antsy+.5), 0, self.cc_character.characteristics.max_antsy)
		self.cc_character.characteristics.current_antsy = new_antsy
