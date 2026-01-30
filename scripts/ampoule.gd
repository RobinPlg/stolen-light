extends MeshInstance3D

@onready var target: Marker3D = $"../../SpringArm3D/Camera3D/Marker3D"
@onready var ship: RigidBody3D = $"../.."

func _process(_delta: float) -> void:
	var local_dir: Vector3 = to_local(target.global_position)
	var pitch: float = atan2(local_dir.y, -local_dir.z)
	rotation.x = pitch
