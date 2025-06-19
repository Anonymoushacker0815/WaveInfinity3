extends Area2D

@export var speed   := 200.0 
@export var damage  := 20    

var velocity := Vector2.ZERO

func _ready():
	var lvl := 1
	var root = get_tree().current_scene
	if root.has_node("LevelManager"):
		lvl = root.get_node("LevelManager").level

	var stat_mult = pow(1.1, lvl - 1)
	speed  *= stat_mult
	damage = int(damage * stat_mult)

	velocity = Vector2.RIGHT.rotated(rotation) * speed

	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

	if body.is_in_group("world_boundary"):
		queue_free()
