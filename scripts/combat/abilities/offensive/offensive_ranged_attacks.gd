extends Resource

var test_bullet: PackedScene = preload("res://scenes/combat/projectiles/test_projectile.tscn")

func shoot_basic_ranged_attack(character: CombatCreatureBaseClass, bullet_spawn_point: Transform2D, damage_amount: int, bullet_speed: int) -> void:
	var direction_vector = character.characteristics.enemy_target.position - character.position
	var angle = direction_vector.angle()
	var spawned_bullet = test_bullet.instantiate()
	
	if character.characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.PLAYER_1:
		spawned_bullet.set_collision_mask_value(3, true)
	elif character.characteristics.character_type == CombatCreatureCharacteristics.CHARACTER_TYPE.NPC_ENEMY:
		spawned_bullet.set_collision_mask_value(1, true)
	spawned_bullet.transform = bullet_spawn_point
	spawned_bullet.damage_amount = damage_amount
	spawned_bullet.speed = bullet_speed
	spawned_bullet.rotation = angle
	character.add_projectile_to_projectile_group("BasicAttack", spawned_bullet)
