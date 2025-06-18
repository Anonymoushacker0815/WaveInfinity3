extends Area2D

@export var speed := 200.0
@export var damage := 20  # Set this in the inspector or dynamically

var velocity := Vector2.ZERO

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
