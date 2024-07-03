class_name CombatCreatureBaseClass

extends CharacterBody2D

var combat_creature_health: int = 0:
	set(value):
		combat_creature_health = value
	get:
		return combat_creature_health
var combat_creature_stamina: int = 0:
	set(value):
		combat_creature_stamina = value
	get:
		return combat_creature_stamina
var combat_creature_speed: int = 0:
	set(value):
		combat_creature_speed = value
	get:
		return combat_creature_speed
		
# ATTACKING
var marker_close: Marker2D
var marker_medium: Marker2D
var marker_far: Marker2D
var character_is_attacking: bool = false

# DODGING
var character_is_dodging: bool = false
var dodge_direction: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	marker_close = $Markers/MarkerClose; assert(marker_close != null, "marker_close wasn't found in player scene tree")
	marker_medium = $Markers/MarkerMedium; assert(marker_medium != null, "marker_medium wasn't found in player scene tree")
	marker_far = $Markers/MarkerFar; assert(marker_far != null, "marker_far wasn't found in player scene tree")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# BASIC MOVEMENT
func _combat_creature_basic_movement(direction: Vector2) -> void:
	#var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * combat_creature_speed
	move_and_slide()

# ATTACKING
func _combat_creature_attack_at_marker_range(range: String) -> void:
	if !character_is_attacking:
		character_is_attacking = true
		$Timers/AttackLockTimer.start()
		match range:
			"close":
				print("Attack made at close range")
			"medium":
				print("Attack made at medium range")
			"far":
				print("Attack made at far range")

func _on_attack_lock_timer_timeout():
	character_is_attacking = false

# DODGING
func _combat_creature_dodge(direction: Vector2) -> void:
	if !character_is_dodging:
		$Timers/DodgeLockTimer.start()
		character_is_dodging = true
		dodge_direction = direction
	
	_combat_creature_continue_dodge()

func _combat_creature_continue_dodge() -> void:
	velocity = dodge_direction * (combat_creature_speed * 5)
	move_and_slide()

func _on_dodge_lock_timer_timeout():
	character_is_dodging = false
