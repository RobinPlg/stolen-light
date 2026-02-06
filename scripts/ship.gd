extends RigidBody3D

@export var max_speed: float = 200.0
@export var min_speed: float = -100.0
@export var acceleration: float = 0.1
@export var brake: float = 0.5
@export var pitch_speed: float= 1.0
@export var roll_speed : float= 1.0
@export var yaw_speed : float= 1.0
@export var input_response : float= 5.0

##@onready var raycast: RayCast3D = $Lampe/RayCast3D
@onready var camera: Camera3D = $NodeCamera3D/PositionCamera3D/Camera3D
##@onready var light : Node3D = $Lampe
var planète : RigidBody3D
@onready var grapin : Node3D = $Grapin/GrapinZone

var speed : Vector3= Vector3.ZERO
var forward_speed : float= 0.0
var pitch_input : float= 0.0
var roll_input : float= 0.0
var yaw_input : float= 0.0
var high_speed : bool= false
var light_mode_state: bool 
var planete_arrimee: RigidBody3D = null

func get_input(delta: float) -> void:

	var throttle_forward :float = 0.0
	var throttle_reverse :float = 0.0

	# Clavier
	if Input.is_action_pressed("throttle_up"):
		throttle_forward = 1.0
	if Input.is_action_pressed("throttle_down"):
		throttle_reverse = 1.0

	# Manette (analogique)
	throttle_forward = max(
		throttle_forward,
		Input.get_action_strength("throttle_up_manette")
	)
	throttle_reverse = max(
		throttle_reverse,
		Input.get_action_strength("throttle_down_manette")
	)

	# Throttle final -1 → +1
	var throttle :float = throttle_forward - throttle_reverse

	# Courbe de réponse douce
	throttle = sign(throttle) * pow(abs(throttle), 1.4)

	# PARAMÈTRES DE MOUVEMENT
	var accel :float= acceleration * 200.0

	if Input.is_action_pressed("stabilize"): 
		forward_speed = lerp(forward_speed, 0.0, brake * delta) 
		angular_damp = 8.0

	elif abs(throttle) > 0.02:
		# Accélération ou marche arrière
		forward_speed += throttle * accel * delta
		high_speed = false

	# ===============================
	# LIMITES DE VITESSE
	# ===============================
	forward_speed = clamp(
		forward_speed,
		min_speed,   # négatif
		max_speed
	)

	if Input.is_action_just_released("stabilize") \
	or Input.is_action_just_released("throttle_down") \
	or Input.is_action_just_released("throttle_up") \
	or Input.is_action_just_released("throttle_up_manette") \
	or Input.is_action_just_released("throttle_down_manette"):
		if forward_speed > 250.0:
			high_speed = true

	if high_speed:
		forward_speed += (250.0 - forward_speed) * 0.03
		if forward_speed <= 250.0:
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
		
		if planete_arrimee:
			planete_arrimee.ship = null
			planete_arrimee = null
			print("planète désarrimée")
		elif grapin.is_planete_here : 
			planete_arrimee = grapin.planete_ready_to_grab
			planete_arrimee.ship = self
			print("planète arrimée")

func _physics_process(delta: float)->void:
	
	get_input(delta)
	
	
	if Input.is_action_just_pressed("light_mode"):
		light_mode_state = !light_mode_state
		
	##if light_mode_state:
		##light_mode_on(delta)
	##else:
		##light_mode_off(delta)
	
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
	
	
##func light_mode_on(delta: float) ->void:
	##light.position.y = lerpf(light.position.y, 0.665, 3.0 * delta) 
	##springarm.position.y = lerpf(springarm.position.y, 2.5, 3.0 * delta) 

##func light_mode_off(delta : float) ->void:
	##light.position.y = lerpf(light.position.y, 0.0 , 3.0 * delta) 
	##3springarm.position.y = lerpf(springarm.position.y, 0.0 , 3.0 * delta) 
	
