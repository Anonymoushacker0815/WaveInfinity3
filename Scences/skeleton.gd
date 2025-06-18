extends CharacterBody2D

@export var speed := 90  # Skeletons might be slightly faster or different
@onready var animated_sprite = $AnimatedSprite2D

var player: Node2D = null

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	add_to_group("skeletons")  # Use a distinct group
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var direction = player.global_position - global_position
	var distance = direction.length()

	if distance > 64:
		direction = direction.normalized()
		velocity = direction * speed
		animated_sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

	move_and_slide()
	# Flip sprite based on movement direction
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
