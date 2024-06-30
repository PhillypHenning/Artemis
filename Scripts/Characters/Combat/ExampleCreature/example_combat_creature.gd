class_name ExampleCreature


extends CombatCreatureBaseClass


# Called when the node enters the scene tree for the first time.
func _ready():
	_abstract_do_ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)


func move(delta: float) -> void:
	var x: float
	var y: float
	var velocity: Vector2
	
	if Input.is_action_pressed("move_right"):
		x += 1
	if Input.is_action_pressed("move_left"):
		x -= 1
	if Input.is_action_pressed("move_down"):
		y += 1
	if Input.is_action_pressed("move_up"):
		y -= 1
	
	velocity = _abstract_determine_velocity(x, y, movement_speed)
	position = _abstract_move_position(delta, velocity)
	_abstract_trigger_moving_animation(velocity)
	_abstract_move_body(position)
