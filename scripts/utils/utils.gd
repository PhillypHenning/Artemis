extends Node

func spawn_packedscene_at_spawn_point(packed_scene: PackedScene, pos: Vector2, node_name: String) -> Node:
	var in_scene = packed_scene.instantiate()
	in_scene.position = pos
	in_scene.name = node_name
	return in_scene
