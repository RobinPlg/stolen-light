extends MeshInstance3D

@onready var target: Marker3D = $"../SpringArm3D2/Camera3D/Marker3D"
@onready var ship: RigidBody3D = $".."

func _physics_process(_delta: float) -> void:
	var dir: Vector3 = target.global_position - global_position
	dir = dir - ship.global_transform.basis.y * dir.dot(ship.global_transform.basis.y)
	dir = dir.normalized()

	look_at(
		global_position + dir,
		ship.global_transform.basis.y
	)
