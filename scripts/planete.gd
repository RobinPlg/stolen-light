extends RigidBody3D

@export_category("References")
var ship: RigidBody3D
@export var ship_hook_path: NodePath
@export var planete_hook_path: NodePath

@export_category("Lock behaviour")
@export var follow_strength := 0.3
@export var velocity_lerp := 0.18
@export var angular_damping := 0.1   
@export var rotation_follow := 0.06

var ship_hook: Node3D
var planete_hook: Node3D
var planete_arrimee : bool


func _ready()-> void:
	
	planete_hook = get_node(planete_hook_path)

	gravity_scale = 0.0


func _physics_process(_delta: float)-> void:
	if Input.is_action_just_pressed("grab_planete") and planete_arrimee == true:
		ship = null
		planete_arrimee = false
		
	if not is_instance_valid(ship):
		return

	ship_hook = ship.get_node(ship_hook_path)
	if not ship_hook:
		return
	_lock_to_ship()
	


# --------------------------------------------------
# Comportement "parenté douce"
# --------------------------------------------------
func _lock_to_ship() -> void:
	
	planete_arrimee = true

	# --- Position (verrouillée douce) ---
	var desired_global: Transform3D = ship_hook.global_transform
	var locked_transform: Transform3D = desired_global * planete_hook.transform.affine_inverse()

	global_position = global_position.lerp(
		locked_transform.origin,
		follow_strength
	)

	# --- Rotation (semi-libre) ---
	var current_basis := global_transform.basis
	var target_basis := locked_transform.basis

	# interpolation partielle de la rotation
	global_transform.basis = current_basis.slerp(
		target_basis,
		0.15  # plus bas = plus libre
	)

	# --- Vitesses ---
	linear_velocity = linear_velocity.lerp(
		ship.linear_velocity,
		velocity_lerp
	)

	# amortissement angulaire
	angular_velocity *= angular_damping
