extends Node3D

@export var orbit_speed := 10.0 
var planete : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate_y(deg_to_rad(orbit_speed) * delta)
	
	if is_instance_valid(planete):
		if planete.planete_arrimee == false: 
			planete.orbit_target = self

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("planete"):
			body.can_orbit = true
			planete = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("planete"):
			if body.planete_arrimee == true:
				body.can_orbit = false
				body.orbit_target = null
				planete = null
