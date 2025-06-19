extends Area2D

@export var speed: float = 800
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("world_boundary"):
		queue_free()
	if body.is_in_group("skeletons") or body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
