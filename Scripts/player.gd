extends CharacterBody2D
@export var player_scene: PackedScene
@export var speed = 300
@export var health = 100
@export var max_health = 100

@export var bullet_scene: PackedScene
@export var fire_rate := 0.2 
var shoot_cooldown := 0.0
var can_shoot = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var gun = $Gun
@onready var shoot_timer = $ShootTimer
@onready var camera = $Camera2D

var facing_right = true

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	add_to_group("player")
	camera.make_current()
	
	if shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	gun.look_at(mouse_pos)
	
	if mouse_pos.x < global_position.x:
		gun.scale.y = -1
	else:
		gun.scale.y = 1
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		shoot_timer.start(fire_rate)

func _physics_process(delta):
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction_input * speed
	
	if direction_input.x != 0:
		facing_right = direction_input.x > 0
		animated_sprite.flip_h = !facing_right
	
	if velocity.length() > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
	
	move_and_slide()

func shoot():
	if bullet_scene == null:
		push_error("No bullet scene assigned!")
		return
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = gun.global_position
	var mouse_pos = get_global_mouse_position()
	bullet.direction = (mouse_pos - global_position).normalized()
	bullet.rotation = bullet.direction.angle()

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	queue_free()

func _on_shoot_timer_timeout():
	can_shoot = true
