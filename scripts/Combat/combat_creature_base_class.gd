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
		
var marker_close: Marker2D
var marker_medium: Marker2D
var marker_far: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	marker_close = $Markers/MarkerClose; assert(marker_close != null, "marker_close wasn't found in player scene tree")
	marker_medium = $Markers/MarkerMedium; assert(marker_medium != null, "marker_medium wasn't found in player scene tree")
	marker_far = $Markers/MarkerFar; assert(marker_far != null, "marker_far wasn't found in player scene tree")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _move_combat_creature(_delta: float, direction: Vector2) -> void:
	#var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * combat_creature_speed
	move_and_slide()

func _attack_at_marker_range(range: String) -> void:
	match range:
		"close":
			print("Attack made at close range")
		"medium":
			print("Attack made at medium range")
		"far":
			print("Attack made at far range")
