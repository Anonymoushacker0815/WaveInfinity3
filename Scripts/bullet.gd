extends Area2D

@export var speed: float = 800
@export var damage: int = 10
@export var max_range: float = 1200.0

var pierce_count: int = 0
var targets_hit: Array = []

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2 = Vector2.ZERO 

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	if global_position.distance_to(start_position) > max_range:
		queue_free()

func set_damage(new_damage: int):
	damage = new_damage

func set_pierce(count: int):
	pierce_count = count

func _on_body_entered(body):
	if body.is_in_group("world_boundary"):
		queue_free()
		return
		
	if (body.is_in_group("skeletons") or body.is_in_group("zombies")) and not body in targets_hit:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			targets_hit.append(body)
			
			if targets_hit.size() > pierce_count:
				queue_free()
