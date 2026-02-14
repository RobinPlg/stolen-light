extends RigidBody3D

@export_category("Variables Grapin")
@export var follow_strength := 0.3
@export var velocity_lerp := 0.18
@export var angular_damping := 0.1   
@export var rotation_follow := 0.06

@export_category("Variables Orbite")
@export var target_orbit : Node3D
@export var orbit_speed :float = 2.0
@export var desired_distance :float = 130.0
@export var radial_strength := 0.02
@export var radial_damping := 0.1

@export_category("References")
@export var ship_hook_path: NodePath
@export var planete_hook_path: NodePath
var ship: RigidBody3D

var ship_hook: Node3D
var planete_hook: Node3D
var planete_arrimee : bool
var can_orbit : bool = true

func _ready()-> void:
	
	planete_hook = get_node(planete_hook_path)
	ship_hook = get_node(ship_hook_path)
	
	if can_orbit == true: 
		
		if target_orbit == null: 
			return
	global_position = target_orbit.global_position + Vector3(0, 0, desired_distance)

	
func _physics_process(delta: float)-> void:
	
	rotate_y(deg_to_rad(15.0) * delta)
	_lock_to_ship()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	if can_orbit == false: 
		return
		
	if target_orbit == null: 
		return
	
	var center := target_orbit.global_position
	var pos := state.transform.origin

	# --- Correction verticale progressive ---
	var vertical_error := center.y - pos.y
	var vertical_force := Vector3(0, vertical_error * radial_strength, 0)
	var vertical_damping_force := Vector3(0, -state.linear_velocity.y * radial_damping, 0)

	# --- Orbite horizontale ---
	var radial := pos - center
	radial.y = 0  # on ignore Y pour l'horizontale
	var distance := radial.length()
	if distance == 0:
		return
	radial = radial.normalized()

	var distance_error := distance - desired_distance
	var radial_force := -radial * distance_error * radial_strength

	var radial_velocity := state.linear_velocity.project(radial)
	var damping_force := -radial_velocity * radial_damping

	var tangent := Vector3(-radial.z, 0, radial.x).normalized()
	var desired_tangent_velocity := tangent * orbit_speed

	# On garde la composante radiale et horizontale de la vitesse tangentielle
	var horizontal_velocity := desired_tangent_velocity + radial_velocity
	state.linear_velocity = Vector3(horizontal_velocity.x, state.linear_velocity.y, horizontal_velocity.z)

	# --- Appliquer toutes les forces ---
	state.apply_central_force(radial_force + damping_force + vertical_force + vertical_damping_force)
	
func _lock_to_ship() -> void:
	
	if ship == null: 
		planete_arrimee = false
		return
	
	planete_arrimee = true

	var desired_global: Transform3D = ship_hook.global_transform
	var locked_transform: Transform3D = desired_global * planete_hook.transform.affine_inverse()

	global_position = global_position.lerp(locked_transform.origin, follow_strength)


	var current_basis := global_transform.basis
	var target_basis := locked_transform.basis

	global_transform.basis = current_basis.slerp(target_basis, 0.15)

	linear_velocity = linear_velocity.lerp(ship.linear_velocity, velocity_lerp)

	angular_velocity *= angular_damping
