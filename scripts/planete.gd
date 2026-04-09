extends RigidBody3D


@export_category("Rotation Planète")
@export var rotation_axis: Vector3 = Vector3(0.2, 1.0, 0.1)  
@export var rotation_speed: float = 15.0

@export_category("Variables Grapin")
@export var follow_strength := 0.3
@export var follow_latency := 0.18
@export var angular_damping := 0.1

@export_category("Dérive Planète")
@export var control_smooth := 0.1
@export var control_derive_sensi := 0.002
var max_derive_offset := 10.0
var control_offset := Vector3.ZERO 
var mouse_delta := Vector2.ZERO

@export_category("Variables Orbite")
@export var orbit_target : Node3D
@export var orbit_speed :float = 2.0
@export var orbit_distance :float = 130.0
@export var orbit_strength := 0.02
@export var orbit_damping := 0.1

@export_category("Variables Dérive Planète")
@export var grapin_move_radius: float = 10.0
@export var grapin_move_speed: float = 0.05
@export var derive_duration_min: float = 3.0
@export var derive_duration_max: float = 6.0
@export var derive_cooldown_min: float = 5.0
@export var derive_cooldown_max: float = 10.0
@export var torque_feedback_strengh : float = 0.15

@export_category("References")
@export var planet_flag : String
@export var ship_hook_path: NodePath
@export var planete_hook_path: NodePath
var ship: RigidBody3D
@onready var mesh_planete : Node3D = $"PlaneteMesh"

var ship_hook: Node3D
var planete_hook: Node3D
var planete_arrimee : bool
var can_orbit : bool = true
var current_input_vec := Vector2.ZERO

func _ready()-> void:
	
	planete_hook = get_node(planete_hook_path)
	ship_hook = get_node(ship_hook_path)
	
	if can_orbit == true: 
		
		if orbit_target == null: 
			return
	global_position = orbit_target.global_position + Vector3(0, 0, orbit_distance)
	
	#angular_velocity = rotation_axis.normalized() * deg_to_rad(rotation_speed)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		control_smooth = 0.4
		
		mouse_delta = event.relative
		mouse_delta.y *= -2.0
		
	else:
		control_smooth = 0.1
	
func _physics_process(delta: float)-> void:
	_lock_to_ship()
	_handle_planet_control(delta)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	if can_orbit == false: 
		return
		
	if orbit_target == null: 
		return
	
	var target_angular_velocity := rotation_axis.normalized() * deg_to_rad(rotation_speed)
	state.angular_velocity = state.angular_velocity.lerp(target_angular_velocity, 0.05)
	
	var center := orbit_target.global_position
	var pos := state.transform.origin
	
	var vertical_error := center.y - pos.y
	var vertical_force := Vector3(0, vertical_error * orbit_strength, 0)
	var vertical_damping_force := Vector3(0, -state.linear_velocity.y * orbit_damping, 0)

	var radial := pos - center
	radial.y = 0 
	var distance := radial.length()
	if distance == 0:
		return
	radial = radial.normalized()

	var distance_error := distance - orbit_distance
	var radial_force := -radial * distance_error * orbit_strength

	var radial_velocity := state.linear_velocity.project(radial)
	var damping_force := -radial_velocity * orbit_damping

	var tangent := Vector3(-radial.z, 0, radial.x).normalized()
	var desired_tangent_velocity := tangent * orbit_speed

	var horizontal_velocity := desired_tangent_velocity + radial_velocity
	state.linear_velocity = Vector3(horizontal_velocity.x, state.linear_velocity.y, horizontal_velocity.z)


	state.apply_central_force(radial_force + damping_force + vertical_force + vertical_damping_force)
	
func _lock_to_ship() -> void:
	
	if ship == null: 
		planete_arrimee = false
		return
	
	planete_arrimee = true

	var desired_transform := Transform3D(ship_hook.global_transform.basis,ship_hook.to_global(control_offset))
	var locked_transform: Transform3D = desired_transform * planete_hook.transform.affine_inverse()

	global_position = global_position.lerp(locked_transform.origin, follow_strength)

	linear_velocity = linear_velocity.lerp(ship.linear_velocity, follow_latency)
	angular_velocity *= angular_damping 

func _handle_planet_control(delta: float) -> void:

	if not GameState.player_can_input:
		return
		
	if planete_arrimee:
		var input_vec := Vector2.ZERO
		
		input_vec.x = Input.get_action_strength("view_right") - Input.get_action_strength("view_left") 
		input_vec.y = Input.get_action_strength("view_up") - Input.get_action_strength("view_down")

		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			input_vec += mouse_delta * control_derive_sensi

		input_vec = input_vec.limit_length(1.0)
		current_input_vec = input_vec
		
		mouse_delta = Vector2.ZERO
		
		var velocity := ship.linear_velocity

		if velocity.length() < 0.1:
			velocity = -ship.global_transform.basis.z

		var local_right := Vector3.RIGHT
		var local_up := Vector3.UP

		var target_offset := (local_right * input_vec.x + local_up * input_vec.y) * max_derive_offset
		target_offset *= max_derive_offset

		control_offset = control_offset.lerp(
			target_offset,
			control_smooth * delta
		)
			
		if not target_offset.is_finite():
			print("TARGET OFFSET INVALID")

		if not control_offset.is_finite():
			print("CONTROL OFFSET INVALID")
		
	else: 
		control_offset = Vector3.ZERO
