extends CharacterBody2D

@export var speed := 80
@onready var animated_sprite = $AnimatedSprite2D

var player: Node2D = null  # Properly declare as a single node

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	add_to_group("zombies")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var direction = player.global_position - global_position
	var distance = direction.length()

	if distance > 64:  # <- Stop pushing when close
		direction = direction.normalized()
		velocity = direction * speed
		animated_sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	move_and_slide()
