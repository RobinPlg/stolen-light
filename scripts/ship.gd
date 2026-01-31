extends RigidBody3D

@export var max_speed: float = 200.0
@export var min_speed: float = -100.0
@export var acceleration: float = 0.1
@export var brake: float = 0.5
@export var pitch_speed: float= 1.0
@export var roll_speed : float= 1.0
@export var yaw_speed : float= 1.0
@export var input_response : float= 5.0

@onready var springarm: SpringArm3D = $SpringArm3D
@onready var raycast: RayCast3D = $Lampe/RayCast3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var light : Node3D = $Lampe
var planète : RigidBody3D
@onready var grapin : Node3D = $Grapin/GrapinZone

var speed : Vector3= Vector3.ZERO
var forward_speed : float= 0.0
var pitch_input : float= 0.0
var roll_input : float= 0.0
var yaw_input : float= 0.0
@export var springarm_length: float = 5.0
@export var base_springarm_length: float = 5.0
@export var max_base_length: float = 25.0
@export var max_springarm_length : float= 6.0
@export var min_springarm_length : float= 4.0
var return_to_springarm_length : bool= false
var high_speed : bool= false
var light_mode_state: bool 

func get_input(delta: float) -> void:
	# --- Accélération ---
	if Input.is_action_pressed("throttle_up"):
		high_speed = false
		forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
		springarm.spring_length = lerp(
			springarm.spring_length,
			base_springarm_length + 1.0,  # recul léger de la caméra
			4.0 * delta
		)
		camera.fov = lerp(camera.fov, 110.0, 2.0 * delta)
		if forward_speed < 150.0:
			camera.shake()

	if Input.is_action_just_released("throttle_up"):
		return_to_springarm_length = true
		if forward_speed > 250.0:
			high_speed = true

	# --- Décélération ---
	if Input.is_action_pressed("throttle_down"):
		forward_speed = lerp(forward_speed, min_speed, acceleration * delta)
		springarm.spring_length = lerp(
			springarm.spring_length,
			base_springarm_length - 1.0,  # avancer légèrement la caméra
			4.0 * delta
		)
		camera.fov = lerp(camera.fov, 75.0, 2.0 * delta)
		if forward_speed > -80.0:
			camera.shake()

	if Input.is_action_just_released("throttle_down"):
		return_to_springarm_length = true

	# --- Stabilisation ---
	if Input.is_action_pressed("stabilize"):
		forward_speed = lerp(forward_speed, 0.0, brake * delta)
		angular_damp = 8.0
		springarm.spring_length = lerp(
			springarm.spring_length,
			base_springarm_length,
			4.0 * delta
		)
		if forward_speed > 5.0:
			camera.fov = lerp(camera.fov, 75.0, 2.0 * delta)
			camera.shake()

	if Input.is_action_just_released("stabilize"):
		return_to_springarm_length = true

	# --- Retour à la distance de base selon la planète ---
	if return_to_springarm_length:
		# Déterminer la distance de base selon la planète accrochée
		if grapin.is_planete_here and grapin.planete_ready_to_grab.planete_arrimee:
			if grapin.planete_ready_to_grab.is_in_group("planete-grosse"):
				springarm.spring_length = lerp(springarm.spring_length,30.0,1.0)
			else:
				springarm.spring_length = lerp(springarm.spring_length,5.0,4.0 * delta)
		
		camera.fov = lerp(camera.fov, 90.0, 2.0 * delta)

		if abs(springarm.spring_length - base_springarm_length) < 0.01:
			return_to_springarm_length = false

	# --- High speed correction ---
	if high_speed:
		forward_speed += (250.0 - forward_speed) * 0.03
		if forward_speed <= 250.0:
			high_speed = false
		
	if Input.is_action_just_pressed("grab_planete") and grapin.is_planete_here:
		grapin.planete_ready_to_grab.ship = self
		print("planète arrimée")
		
	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"), input_response * delta)
	roll_input = lerp(roll_input, Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"), input_response * delta)
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"), input_response * delta)

func _physics_process(delta: float)->void:
	get_input(delta)
	var torque := Vector3.ZERO
	if abs(roll_input) < 0.01 and abs(pitch_input) < 0.01 and abs(yaw_input) < 0.01:
		angular_damp = 6.0
	else:
		angular_damp = 1.5
	torque += transform.basis.z * roll_input * roll_speed
	torque += transform.basis.x * pitch_input * pitch_speed
	torque += transform.basis.y * yaw_input * yaw_speed
	apply_torque(torque)
	apply_central_force(-transform.basis.z * forward_speed)
	
	
	if Input.is_action_just_pressed("light_mode"):
		light_mode_state = !light_mode_state
		
	if light_mode_state:
		light_mode_on(delta)
	else:
		light_mode_off(delta)

func light_mode_on(delta: float) ->void:
	light_mode_state = true
	light.position.y = lerpf(light.position.y, 0.665, 3.0 * delta) 
	springarm.position.y = lerpf(springarm.position.y, 2.5, 3.0 * delta) 

func light_mode_off(delta : float) ->void:
	light_mode_state = false
	light.position.y = lerpf(light.position.y, 0.0 , 3.0 * delta) 
	springarm.position.y = lerpf(springarm.position.y, 0.0 , 3.0 * delta) 
	
