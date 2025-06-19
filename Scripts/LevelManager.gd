extends Node2D

# Scenes
@export var player_scene: PackedScene
@export var zombie_scene: PackedScene
@export var skeleton_scene: PackedScene
@export var reticle_scene: PackedScene

# Base counts & exponential multipliers
@export var base_zombie_count   := 10
@export var base_skeleton_count := 5
@export var zombie_multiplier   := 1.5
@export var skeleton_multiplier := 1.4

# Map spawning bounds
@export var map_size     := Vector2(4096, 4096)
@export var edge_margin  := 100.0
@export var min_distance := 64.0

# Runtime state
var level := 1
var alive_mobs := 0
var spawn_positions: Array[Vector2] = []

# UI nodes
@onready var death_screen   = get_node("../DeathScreen")
@onready var restart_button = get_node("../DeathScreen/VBoxContainer/Button")

func _ready():
	# Keep the death screen and button interactive when paused
	death_screen.process_mode   = Node.PROCESS_MODE_WHEN_PAUSED
	restart_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Start game
	spawn_player()
	start_level(level)

	restart_button.pressed.connect(self.on_restart_button_pressed)

func spawn_player():
	var player = player_scene.instantiate()
	player.position = map_size / 2
	add_child(player)

	player.initialize_ui()
	player.initialize_camera()
	player.died.connect(self.on_player_died)

func start_level(current_level: int):
	spawn_positions.clear()

	# calculate counts exponentially: base * multiplier^(level-1)
	var zombies_to_spawn   = int(base_zombie_count   * pow(zombie_multiplier,   current_level - 1))
	var skeletons_to_spawn = int(base_skeleton_count * pow(skeleton_multiplier, current_level - 1))

	alive_mobs = zombies_to_spawn + skeletons_to_spawn

	spawn_mobs(zombie_scene,   zombies_to_spawn)
	spawn_mobs(skeleton_scene, skeletons_to_spawn)

	update_level_label(current_level)

func spawn_mobs(scene: PackedScene, count: int):
	var attempts = 0
	var target = spawn_positions.size() + count
	while spawn_positions.size() < target and attempts < count * 10:
		var pos = get_random_edge_position()
		if is_far_enough(pos):
			spawn_positions.append(pos)
			var mob = scene.instantiate()
			mob.position = pos
			call_deferred("_deferred_spawn_mob", mob)
		attempts += 1

# run just after the current physics/idle flush:
func _deferred_spawn_mob(mob: Node):
	add_child(mob)
	mob.died.connect(self.on_mob_died)


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
	var player_center = map_size / 2
	if pos.distance_to(player_center) < min_distance * 2:
		return false
	for other in spawn_positions:
		if pos.distance_to(other) < min_distance:
			return false
	return true

func on_mob_died():
	alive_mobs -= 1
	if alive_mobs <= 0:
		# wave cleared → next level
		level += 1
		start_level(level)

func update_level_label(current_level: int):
	var lbl = get_node("../CanvasLayer/LevelLabel")
	lbl.text = "Level %d" % current_level

func on_player_died():
	get_tree().paused = true
	death_screen.visible = true

func on_restart_button_pressed():
	get_tree().paused = false
	death_screen.visible = false
	get_tree().reload_current_scene()
