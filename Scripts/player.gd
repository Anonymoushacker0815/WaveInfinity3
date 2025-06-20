extends CharacterBody2D
signal died
@export var player_scene: PackedScene
@export var speed = 300
@export var health = 100
@export var max_health = 100

@export var bullet_scene: PackedScene
@export var fire_rate := 0.5
var shoot_cooldown := 0.0
var can_shoot = true
var bullet_damage: int = 10

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var gun = $Gun
@onready var shoot_timer = $ShootTimer
@onready var camera = $Camera2D
@onready var reticle = $Reticle
@onready var flash = $Gun/MuzzleFlash

var facing_right = true

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	shoot_timer.wait_time = fire_rate
	add_to_group("player")
	camera.make_current()
	flash.visible = false
	$Gun/MuzzleFlash.animation_finished.connect(_on_muzzle_flash_finished)
	
	reticle.show()
	reticle.global_position = get_global_mouse_position()
	


func _process(delta):
	var mouse_pos = get_global_mouse_position()
	flash.flip_h = !facing_right
	if Input.is_action_pressed("shoot") and can_shoot:
		facing_right = mouse_pos.x > global_position.x
		animated_sprite.flip_h = !facing_right
		gun.scale.y = -1 if !facing_right else 1
		
		shoot()
		can_shoot = false
		shoot_timer.start(fire_rate)
	if facing_right:
		flash.position = Vector2(10, -12)  
		$Gun/BulletSpawnPoint.position = Vector2(12, 1)
	else:
		flash.position = Vector2(-13, -14) 
		$Gun/BulletSpawnPoint.position = Vector2(-12, -1)

func _physics_process(delta):
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction_input * speed
	flash.flip_h = !facing_right
	
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
	
func set_health(new_health: float):
	health = new_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	print("Set health to: ", health)
	
func set_bullet_damage(new_damage: int):
	bullet_damage = new_damage
	print("Set bullet damage to: ", bullet_damage)

func set_fire_rate(new_rate: float):
	fire_rate = new_rate
	shoot_timer.wait_time = fire_rate
	print("Set fire rate to: ", fire_rate)
	
func set_movement_speed(new_speed: float):
	speed = new_speed
	print("Set movement speed to: ", speed)
	
func initialize_stats(speed: float, fire_rate: float, damage: float):
	self.speed = speed
	self.fire_rate = fire_rate
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		if bullet.has_method("set_damage"):
			bullet.set_damage(damage)

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
	
	bullet.global_position = $Gun/BulletSpawnPoint.global_position
	bullet.direction = ($Reticle.global_position - bullet.global_position).normalized()
	bullet.rotation = bullet.direction.angle()
	bullet.damage = bullet_damage  
	
	print("Fired bullet with damage: ", bullet.damage)

	# Show muzzle flash
	var muzzle_flash = $Gun.get_node("MuzzleFlash")
	muzzle_flash.show()
	muzzle_flash.flip_h = !facing_right
	muzzle_flash.play("flash") 

func _on_muzzle_flash_finished():
	$Gun/MuzzleFlash.hide()
	
func take_damage(amount):
	health -= amount
	health_bar.value = health
	print("%s took %d damage, health now: %d" % [name, amount, health])
	if health <= 0:
		die()

func die():
	emit_signal("died")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_free()


func _on_shoot_timer_timeout():
	can_shoot = true
