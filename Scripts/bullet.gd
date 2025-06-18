extends Area2D

@export var speed: float = 800
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready():
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
