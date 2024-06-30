class_name CombatCreatureBaseClass


extends Node

# Interfaced
@export var health_points: int
@export var action_points: int
@export var movement_speed: int
# Non-Interfaced
var screen_size
var velocity: Vector2 = Vector2.ZERO
var position: Vector2
# Expected child nodes
var child_area2d: Area2D
var child_animated_sprite2d: AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _abstract_do_ready() -> void:
	child_area2d = find_child("Body")
	screen_size = child_area2d.get_viewport_rect().size

	child_animated_sprite2d = find_child("AnimatedSprite2D")


func _abstract_determine_velocity(x: float, y: float, movement_speed: int) -> Vector2:
	velocity = Vector2.ZERO
	velocity.x = x
	velocity.y = y
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * movement_speed
	
	return velocity


func _abstract_move_position(delta: float, velocity: Vector2) -> Vector2:
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	return position


func _abstract_trigger_moving_animation(velocity: Vector2) -> void:
	if child_animated_sprite2d != null:
		if velocity.length() > 0:
			child_animated_sprite2d.play()
		else:
			child_animated_sprite2d.stop()
		if velocity.x != 0:
			child_animated_sprite2d.animation = "walk"
			child_animated_sprite2d.flip_v = false
			# See the note below about boolean assignment.
			child_animated_sprite2d.flip_h = velocity.x < 0
		elif velocity.y != 0:
			child_animated_sprite2d.animation = "up"
			child_animated_sprite2d.flip_v = velocity.y > 0


func _abstract_move_body(position: Vector2) -> void:
	child_area2d.position = position
