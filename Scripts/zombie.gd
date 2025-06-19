extends CharacterBody2D
signal died

@export var speed := 80
@export var max_health := 30

# NEW: how much damage each hit does
@export var damage := 10
# NEW: distance at which the zombie stops and attacks
@export var attack_range := 64
# NEW: seconds between attacks
@export var attack_cooldown := 1.0

@onready var animated_sprite = $AnimatedSprite2D

var player: Node2D = null
var health := max_health

# NEW: Timer for pacing attacks
var attack_timer: Timer

func _ready():
	# find the player
	var players = get_tree().get_nodes_in_group("player")
	add_to_group("zombies")
	if players.size() > 0:
		player = players[0]

	# set up attack timer
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = false
	attack_timer.autostart = true
	add_child(attack_timer)
	attack_timer.timeout.connect(self._on_attack_timer_timeout)

func take_damage(amount: int):
	health -= amount
	print("%s took %d damage, health now: %d" % [name, amount, health])
	if health <= 0:
		die()

func die():
	print("%s died." % name)
	emit_signal("died")
	queue_free()

func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var direction = player.global_position - global_position
	var distance = direction.length()

	if distance > attack_range:
		# chase
		direction = direction.normalized()
		velocity = direction * speed
		animated_sprite.play("walk")
	else:
		# in range — stop and idle
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	move_and_slide()

	# flip sprite to face the player
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

# called every attack_cooldown seconds
func _on_attack_timer_timeout() -> void:
	if player == null or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) <= attack_range:
		# damage the player
		player.take_damage(damage)
