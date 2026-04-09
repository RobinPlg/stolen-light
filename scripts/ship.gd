extends RigidBody3D

@export_category("Variables Vaisseau")
@export var max_speed: float = 200.0
@export var min_speed: float = -100.0
@export var acceleration: float = 0.1
@export var brake: float = 0.5
@export var pitch_speed: float= 1.0
@export var roll_speed : float= 1.0
@export var yaw_speed : float= 1.0
@export var input_response : float= 5.0

var grapin_move_radius: float
var grapin_move_speed: float
var derive_cooldown_min: float
var derive_cooldown_max: float
var derive_duration_min: float
var derive_duration_max: float
var torque_feedback_strengh : float

@onready var node_grapin_ship: Node3D = $NodeGrapinShip
@onready var camera: Camera3D = $NodeCamera3D/PositionCamera3D/MainCamera
@onready var grapin : Node3D = $Grapin/GrapinZone
var planète : RigidBody3D

var speed : Vector3= Vector3.ZERO
var forward_speed : float= 0.0
var pitch_input : float= 0.0
var roll_input : float= 0.0
var yaw_input : float= 0.0
var high_speed : bool= false
var can_move : int = 1
var planete_arrimee: RigidBody3D = null

var current_dir: Vector3 = Vector3.ZERO
@onready var derive_timer: float = 0.0
@onready var derive_cooldown: float = randf_range(derive_cooldown_min, derive_cooldown_max)
var current_duration: float = 0.0
var grapin_offset: Vector3 = Vector3.ZERO
var target_dir: Vector3 = Vector3.ZERO
var is_deriving: bool = false

func get_input(delta: float) -> void:

	var throttle_forward :float = 0.0
	var throttle_reverse :float = 0.0

	# Clavier
	if Input.is_action_pressed("throttle_up"):
		throttle_forward = 1.0 
	if Input.is_action_pressed("throttle_down"):
		throttle_reverse = 1.0

	# Manette
	throttle_forward = max(
		throttle_forward,
		Input.get_action_strength("throttle_up_manette")
	)
	throttle_reverse = max(
		throttle_reverse,
		Input.get_action_strength("throttle_down_manette")
	)

	var throttle :float = throttle_forward - throttle_reverse

	throttle = sign(throttle) * pow(abs(throttle), 1.4)
	
	var accel :float= acceleration * 200.0

	if Input.is_action_pressed("stabilize"): 
		forward_speed = lerp(forward_speed, 0.0, brake * delta) 
		angular_damp = 8.0

	elif abs(throttle) > 0.02:
		forward_speed += throttle * accel * delta
		high_speed = false

	forward_speed = clamp(
		forward_speed,
		min_speed,
		max_speed
	) * can_move

	if Input.is_action_just_released("stabilize") \
	or Input.is_action_just_released("throttle_down") \
	or Input.is_action_just_released("throttle_up") \
	or Input.is_action_just_released("throttle_up_manette") \
	or Input.is_action_just_released("throttle_down_manette"):
		if forward_speed > 250.0:
			high_speed = true

	if high_speed:
		forward_speed += (250.0 - forward_speed) * 0.03
		camera.fov = lerp(camera.fov, 80.0, 2.0 * delta)
		camera.shake()
		if forward_speed <= 250.9:
			camera.fov = lerp(camera.fov, 90.0, 2.0 * delta)
			high_speed = false

	# CAMERA SHAKE
	if abs(throttle) > 0.1 or Input.is_action_pressed("stabilize") :
		if forward_speed < 3.0 and forward_speed > -3.0 :
			return
		if forward_speed < 130.0 and forward_speed > -50.0 :
			camera.shake()
		
	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"), input_response * delta)
	roll_input = lerp(roll_input, Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"), input_response * delta)
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"), input_response * delta)

	if Input.is_action_just_pressed("grab_planete") :
	
		## Désarrimage Planète
		if planete_arrimee:
			GameState.flags.erase(planete_arrimee.planet_flag)
			planete_arrimee.ship = null
			planete_arrimee.can_orbit = true
			planete_arrimee = null

		## Arrimage Planète
		elif grapin.is_planete_here : 
			planete_arrimee = grapin.planete_ready_to_grab
			planete_arrimee.can_orbit = false
			planete_arrimee.ship = self
			planete_arrimee.orbit_target = null
			grapin_move_radius = planete_arrimee.grapin_move_radius
			grapin_move_speed = planete_arrimee.grapin_move_speed
			derive_duration_min = planete_arrimee.derive_duration_min
			derive_duration_max = planete_arrimee.derive_duration_max
			derive_cooldown_min = planete_arrimee.derive_cooldown_min
			derive_cooldown_max = planete_arrimee.derive_cooldown_max
			torque_feedback_strengh  = planete_arrimee.torque_feedback_strengh
			GameState.set_flag(planete_arrimee.planet_flag)
			print(GameState.flags)

func _physics_process(delta: float)->void:
	
	if not GameState.player_can_input:
		return
		
	get_input(delta)
	
	if planete_arrimee :
		update_grapin_random_motion(delta)
		if planete_arrimee.current_input_vec.length() > 0.01:
			var torque_feedback := Vector3.ZERO
			torque_feedback += transform.basis.y * (-planete_arrimee.control_offset.x * torque_feedback_strengh)
			torque_feedback += transform.basis.x * (-planete_arrimee.control_offset.y * torque_feedback_strengh)
			apply_torque(torque_feedback)
	else:
		grapin_offset = grapin_offset.lerp(Vector3.ZERO, 5.0 * delta)
		apply_torque(Vector3.ZERO)
		node_grapin_ship.position = grapin_offset

	var torque := Vector3.ZERO
	if abs(roll_input) < 0.01 and abs(pitch_input) < 0.01 and abs(yaw_input) < 0.01:
		angular_damp = 6.0
	else:
		angular_damp = 1.5
	torque += transform.basis.z * roll_input * roll_speed
	torque += transform.basis.x * pitch_input * pitch_speed
	torque += transform.basis.y * yaw_input * yaw_speed
	apply_torque(torque * can_move)
	apply_central_force(-transform.basis.z * forward_speed)
	
func update_grapin_random_motion(delta: float) -> void:

	if is_deriving:
		derive_timer -= delta
		camera.random_strength = 0.005
		camera.shake()
		if derive_timer <= 0.0:
			is_deriving = false
			derive_cooldown = randf_range(derive_cooldown_min, derive_cooldown_max)
			return
			
		current_dir = current_dir.slerp(target_dir, 3.0 * delta)
		var target_offset := current_dir * grapin_move_radius
		
		grapin_offset = grapin_offset.lerp(target_offset, grapin_move_speed * delta)
		
	else:
		derive_cooldown -= delta
		grapin_offset = grapin_offset.lerp(Vector3.ZERO, delta)
		if derive_cooldown <= 0.0:
			start_new_derive()

	node_grapin_ship.position = grapin_offset
	
func start_new_derive() -> void:
	is_deriving = true
	derive_timer = randf_range(derive_duration_min, derive_duration_max)
	pick_new_random_direction()
	
func pick_new_random_direction() -> void:

	var random_2d := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()

	target_dir = Vector3(random_2d.x, random_2d.y, 0.0).normalized()

func _on_body_entered(body: Node) -> void:
	if body is RigidBody3D:
		
		var collision_normal:Vector3 = (global_position - body.global_position).normalized()
		
		linear_velocity = linear_velocity.bounce(collision_normal)
		
		if body.is_in_group("planete") and planete_arrimee == null:
			forward_speed *= -0.1
		elif body.is_in_group("planete") and planete_arrimee != null:
			forward_speed *= 0.5
