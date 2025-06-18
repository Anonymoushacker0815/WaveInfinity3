extends Node2D

@export var player_scene: PackedScene
@export var zombie_scene: PackedScene
@export var skeleton_scene: PackedScene  # New export
@export var base_zombie_count := 5
@export var base_skeleton_count := 3     # New: base skeleton count
@export var map_size := Vector2(2048, 2048)
@export var edge_margin := 100.0
@export var min_distance := 64.0

var level := 1
var spawn_positions: Array[Vector2] = []

func _ready():
	spawn_player()
	start_level(level)
	
	
func spawn_player():
	var player_instance = player_scene.instantiate()
	player_instance.position = map_size / 2
	add_child(player_instance)
	
	# Make sure these are called after player is added to tree
	player_instance.initialize_ui()
	player_instance.initialize_camera()

func start_level(current_level: int):
	spawn_positions.clear()
	
	var zombies_to_spawn = base_zombie_count + (current_level - 1) * 2
	var skeletons_to_spawn = base_skeleton_count + (current_level - 1) * 1
	
	spawn_mobs(zombie_scene, zombies_to_spawn)
	spawn_mobs(skeleton_scene, skeletons_to_spawn)  # New call
	
	update_level_label(current_level)

func spawn_mobs(scene: PackedScene, count: int):
	var attempts = 0
	while spawn_positions.size() < count + spawn_positions.size() and attempts < count * 10:
		var pos = get_random_edge_position()
		if is_far_enough(pos):
			spawn_positions.append(pos)
			var mob = scene.instantiate()
			mob.position = pos
			add_child(mob)
		attempts += 1

func get_random_edge_position() -> Vector2:
	var side = randi_range(0, 3)
	var x = randf_range(0, map_size.x)
	var y = randf_range(0, map_size.y)

	match side:
		0: x = randf_range(0, edge_margin)
		1: x = map_size.x - randf_range(0, edge_margin)
		2: y = randf_range(0, edge_margin)
		3: y = map_size.y - randf_range(0, edge_margin)

	return Vector2(x, y)

func is_far_enough(pos: Vector2) -> bool:
	var player_pos = map_size / 2
	if pos.distance_to(player_pos) < min_distance * 2:
		return false
	for existing in spawn_positions:
		if pos.distance_to(existing) < min_distance:
			return false
	return true

func update_level_label(current_level: int):
	var label = get_node("../CanvasLayer/LevelLabel")
	label.text = "Level %d" % current_level

func next_level():
	level += 1
	start_level(level)
