extends Camera3D

@export var random_strength: float= 0.01
@export var shake_fade: float = 2.0

var shake_strength: float = 0.0
var initial_transform: Transform3D

func shake()-> void:
	initial_transform = self.transform
	shake_strength = random_strength

func random_offset()-> Vector3:
	return Vector3(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength),
		0.0
	)

func _physics_process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0 , shake_fade * delta)
		self.transform.origin = initial_transform.origin + random_offset()
	else:
		shake_strength = 0.0 
