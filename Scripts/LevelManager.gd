extends Node2D

# Scenes
@export var player_scene: PackedScene
@export var zombie_scene: PackedScene
@export var skeleton_scene: PackedScene
@export var reticle_scene: PackedScene
@export var upgrade_menu_scene: PackedScene

# Base counts & exponential multipliers
@export var base_zombie_count   := 10
@export var base_skeleton_count := 5
@export var zombie_multiplier   := 1.2
@export var skeleton_multiplier := 1.1

# Base Player stats
@export var base_player_health := 100.0
@export var base_player_speed := 300.0
@export var base_player_fire_rate := 0.5
@export var base_player_damage := 10.0

# Current Player stats
var current_player_health: float
var current_player_speed: float
var current_player_fire_rate: float
var current_player_damage: float
var upgrade_menu: CanvasLayer = null

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
@onready var restart_button = get_node("../DeathScreen/VBoxContainer/RestartButton")
@onready var home_button  = get_node("../DeathScreen/VBoxContainer/HomeButton") 

func _ready():
	death_screen.process_mode   = Node.PROCESS_MODE_WHEN_PAUSED
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	home_button.process_mode    = Node.PROCESS_MODE_ALWAYS

	reset_player_stats()
	spawn_player()
	start_level(level)

	restart_button.pressed.connect(on_restart_button_pressed)
	home_button.pressed.connect(on_home_button_pressed)
	
func reset_player_stats():
	current_player_health = base_player_health
	current_player_speed = base_player_speed
	current_player_fire_rate = base_player_fire_rate
	current_player_damage = base_player_damage

func spawn_player():
	var player = player_scene.instantiate()
	player.position = map_size / 2
	add_child(player)
	player.initialize_ui()
	player.initialize_camera()
	player.died.connect(on_player_died)

func start_level(current_level: int):
	spawn_positions.clear()

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

func _deferred_spawn_mob(mob: Node):
	add_child(mob)
	mob.died.connect(on_mob_died)

	var stat_mult = pow(1.1, level - 1)

	mob.speed         *= stat_mult
	mob.max_health    = int(mob.max_health * stat_mult)
	mob.health        = mob.max_health

	if mob.is_in_group("zombies"):
		mob.damage = int(mob.damage * stat_mult)
		mob.attack_cooldown    /= stat_mult
		mob.attack_timer.wait_time = mob.attack_cooldown

	elif mob.is_in_group("skeletons"):
		mob.shoot_cooldown    /= stat_mult
		mob.shoot_timer.wait_time = mob.shoot_cooldown
		mob.shoot_distance *= stat_mult

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
	
	await get_tree().process_frame
	
	if alive_mobs <= 0:
		var mobs = get_tree().get_nodes_in_group("zombies") + get_tree().get_nodes_in_group("skeletons")
		if mobs.size() == 0:
			show_upgrade_menu()
		else:
			alive_mobs = mobs.size() 
			
func show_upgrade_menu():
	if upgrade_menu:
		upgrade_menu.queue_free()
		await get_tree().process_frame
		upgrade_menu = null

	get_tree().paused = true
	upgrade_menu = upgrade_menu_scene.instantiate()
	add_child(upgrade_menu)
	upgrade_menu.set_level(level)
	upgrade_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	upgrade_menu.upgrade_selected.connect(upgrade_stat, CONNECT_ONE_SHOT)
	upgrade_menu.continue_pressed.connect(continue_to_next_level, CONNECT_ONE_SHOT)

func upgrade_stat(stat: String, percent_increase: float, is_special: bool):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if is_special:
		match stat:
			"health":
				player.extra_bullets += 1
				print("Extra Bullets:", player.extra_bullets)
			"speed":
				player.pierce_count += 1
			"fire_rate":
				player.spread_level += 1
				print("Spread Level:", player.spread_level)
			"damage":
				player.bullet_speed_multiplier += 0.3
	else:
		match stat:
			"health":
				var new_health = player.max_health * (1 + percent_increase)
				player.max_health = new_health
				player.set_health(new_health) 
			"speed":
				var new_speed = player.speed * (1 + percent_increase)
				player.set_movement_speed(new_speed)
			"fire_rate":
				var new_rate = player.fire_rate * (1 - percent_increase)  
				player.set_fire_rate(max(0.05, new_rate))
			"damage":
				var new_damage = player.bullet_damage * (1 + percent_increase)
				player.set_bullet_damage(new_damage)

func continue_to_next_level():
	if upgrade_menu:
		upgrade_menu.queue_free()
		await get_tree().process_frame 
		upgrade_menu = null
		
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	level += 1
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health = player.max_health
		player.health_bar.value = player.health

	start_level(level)

func update_level_label(current_level: int):
	var lbl = get_node("../LevelLabel/LevelLabel")
	lbl.text = "Level %d" % current_level

func on_player_died():
	get_tree().paused = true
	death_screen.visible = true

func on_restart_button_pressed():
	get_tree().paused = false
	death_screen.visible = false
	get_tree().reload_current_scene()

func on_home_button_pressed():
	get_tree().paused = false
	death_screen.visible = false
	get_tree().change_scene_to_file("res://Scenes/home_screen.tscn")
