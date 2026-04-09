extends RigidBody3D

@export var speed: float = 300.0
@export var lifetime: float = 5.0

func launch(direction: Vector3) -> void:
	linear_velocity = direction * speed
	await get_tree().create_timer(lifetime).timeout
	queue_free()
