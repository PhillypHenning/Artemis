extends Area2D

var speed: int
var damage_amount: int

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.combat_creature_nodes:
		body._use_combat_creature_take_damage(damage_amount)
	queue_free()
