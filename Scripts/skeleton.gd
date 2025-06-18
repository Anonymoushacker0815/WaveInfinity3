extends CharacterBody2D

@export var speed := 90
@export var max_health := 30
@export var fireball_scene: PackedScene
@export var shoot_distance := 300  # Adjusted here
@export var shoot_cooldown := 1.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var shoot_timer: Timer = $ShootTimer

var player: Node2D = null
var health := max_health

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	add_to_group("skeletons")
	if players.size() > 0:
		player = players[0]

	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.start()
	
func take_damage(amount: int):
	health -= amount
	print("%s took %d damage, health now: %d" % [name, amount, health])
	if health <= 0:
		die()

func die():
	print("%s died." % name)
	queue_free()

func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var direction = player.global_position - global_position
	var distance = direction.length()

	# Flip sprite
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

	if distance < shoot_distance:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
	else:
		direction = direction.normalized()
		velocity = direction * speed
		animated_sprite.play("walk")

	move_and_slide()

func _on_shoot_timer_timeout() -> void:
	if player == null or not is_instance_valid(player):
		return

	var distance = player.global_position.distance_to(global_position)
	if distance <= shoot_distance:
		shoot()

func shoot():
	if fireball_scene == null:
		push_warning("No fireball_scene assigned!")
		return

	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position

	var direction = (player.global_position - global_position).normalized()
	fireball.rotation = direction.angle()

	get_tree().current_scene.add_child(fireball)
