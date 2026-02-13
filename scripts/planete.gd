extends RigidBody3D

@export_category("Variables Grapin")
@export var follow_strength := 0.3
@export var velocity_lerp := 0.18
@export var angular_damping := 0.1   
@export var rotation_follow := 0.06

@export_category("Variables Orbite")
@export var target_orbit : Node3D
@export var speed_orbit :float = 40.0
@export var distance :float = 5.0
var current_angle_orbit :float = 0.0

@export_category("References")
var ship: RigidBody3D
@export var ship_hook_path: NodePath
@export var planete_hook_path: NodePath



var ship_hook: Node3D
var planete_hook: Node3D
var planete_arrimee : bool
var can_orbit : bool = true


func _ready()-> void:
	
	planete_hook = get_node(planete_hook_path)
	ship_hook = get_node(ship_hook_path)

func _physics_process(delta: float)-> void:
	
	rotate_y(deg_to_rad(15.0) * delta)
	orbit(delta)
	_lock_to_ship()
	
func orbit(delta: float) -> void:
	
	if can_orbit == true:
		
		if target_orbit == null:
			return
		
		current_angle_orbit += deg_to_rad(speed_orbit) * delta
	
		var x : float= target_orbit.global_position.x + cos(current_angle_orbit) * distance
		var z : float = target_orbit.global_position.z + sin(current_angle_orbit) * distance
	
		global_position = Vector3(x, target_orbit.global_position.y, z)
	
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
