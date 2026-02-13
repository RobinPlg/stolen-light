extends Node3D

@export var orbit_speed := 10.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate_y(deg_to_rad(orbit_speed) * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("planete"):
			body.target_orbit = self

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("planete"):
			body.can_orbit = false
