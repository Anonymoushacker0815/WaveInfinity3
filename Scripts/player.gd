extends CharacterBody2D
signal died
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
@onready var reticle = $Reticle

var facing_right = true

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	add_to_group("player")
	camera.make_current()
	
	reticle.show()
	reticle.global_position = get_global_mouse_position()
	
	if shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	gun.look_at(mouse_pos)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		facing_right = mouse_pos.x > global_position.x
		animated_sprite.flip_h = !facing_right
		gun.scale.y = -1 if !facing_right else 1
		
		shoot()
		can_shoot = false
		shoot_timer.start(fire_rate)

func _physics_process(delta):
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction_input * speed
	
	if can_shoot:  
		if abs(direction_input.x) > 0.1: 
			facing_right = direction_input.x > 0
		else:  
			var mouse_pos = get_global_mouse_position()
			facing_right = mouse_pos.x > global_position.x
		
		animated_sprite.flip_h = !facing_right
		gun.scale.y = -1 if !facing_right else 1
	
	if velocity.length() > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
	
	move_and_slide()

func initialize_ui():
	if has_node("Reticle"):
		$Reticle.show()
		$Reticle.global_position = global_position
	else:
		push_error("Reticle node missing!")
	
	health_bar.max_value = max_health
	health_bar.value = health

func initialize_camera():
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func shoot():
	if bullet_scene == null:
		push_error("No bullet scene assigned!")
		return
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	
	bullet.global_position = $Gun.global_position
	var mouse_pos = get_global_mouse_position()
	bullet.direction = (mouse_pos - global_position).normalized()
	bullet.rotation = bullet.direction.angle()
	
	print("Bullet spawned at: ", bullet.global_position, 
		  " Gun at: ", $Gun.global_position,
		  " Player at: ", global_position)

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	emit_signal("died")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_free()


func _on_shoot_timer_timeout():
	can_shoot = true
