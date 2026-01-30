extends Area3D

var is_planete_here: bool
var planete_ready_to_grab : RigidBody3D = null

func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body : RigidBody3D) -> void:
	if body.is_in_group("planete"):
		print("planète détecté")
		is_planete_here = true
		planete_ready_to_grab = body

func _on_body_exited(body: RigidBody3D) -> void:
	if body.is_in_group("planete"):
		print("planète perdue")
		is_planete_here = false
		planete_ready_to_grab = null
