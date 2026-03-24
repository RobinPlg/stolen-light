extends Node3D

var offset: Vector3
@export var base_offset: Vector3 = Vector3(0, 0, 5) 
var return_to_base_offset_bool : bool = false

@export var movement_offset_strength := 0.2
@export var movement_offset_smooth := 5.0
var movement_offset := Vector3.ZERO

@onready var ship: Node3D = $"../.."
@onready var camera_rotation: Node3D = $".."
@onready var grapin: Node3D = $"../../Grapin/GrapinZone"
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	offset = base_offset

func _process(delta: float) -> void:
	var cam_rotation : Vector3 = camera_rotation.get_camera_rotation()
	var cam_transform: Transform3D = Transform3D.IDENTITY
	var throttle_up_strength := Input.get_action_strength("throttle_up_manette")
	var throttle_down_strength := Input.get_action_strength("throttle_down_manette")
	
	check_planete()

	var ang_local : Vector3= ship.global_transform.basis.inverse() * ship.angular_velocity

	var target_movement_offset : Vector3 = Vector3(
	-ang_local.y , 
	 ang_local.x * 0.5 , 
	0
	) * movement_offset_strength * ship.forward_speed * 0.02

	movement_offset = movement_offset.lerp(
		target_movement_offset,
		movement_offset_smooth * delta
	)

	## Adaptation de la caméra en foction des actions
	if Input.is_action_pressed("throttle_up"):
		offset = lerp(offset, base_offset + Vector3(0, 0, 15), 0.2 * delta)
		camera.fov = lerp(camera.fov, 100.0, 2.0 * delta)
	if Input.is_action_pressed("throttle_up_manette") and throttle_up_strength > 0.5:
		offset = lerp(offset, base_offset + Vector3(0, 0, 15), 0.2 * delta)
		camera.fov = lerp(camera.fov, 100.0, 2.0 * delta)
	if Input.is_action_pressed("throttle_down_manette") and throttle_down_strength > 0.5:
		offset = lerp(offset, base_offset - Vector3(0, 0, 1), delta) 
		camera.fov = lerp(camera.fov, 80.0, 2.0 * delta)
	if Input.is_action_pressed("throttle_down"):
		offset = lerp(offset, base_offset - Vector3(0, 0, 1), delta) 
		camera.fov = lerp(camera.fov, 80.0, 2.0 * delta)
	if Input.is_action_pressed("stabilize"):
		offset = lerp(offset, base_offset - Vector3(0, 0, 1), 2.0 * delta) 
		camera.fov = lerp(camera.fov, 80.0, 2.0 * delta)

	return_to_base_offset(delta)
	
	cam_transform = cam_transform.translated(offset + movement_offset)
	cam_transform = cam_transform.rotated(Vector3.RIGHT, deg_to_rad(cam_rotation.x))
	cam_transform = cam_transform.rotated(Vector3.UP, deg_to_rad(cam_rotation.y))

	var target_position: Transform3D = ship.global_transform * cam_transform
	global_transform = target_position

func check_planete() -> void: 
	
	## Adaptation de la distance de la caméra en foction de la planète
	if grapin.planete_ready_to_grab != null and grapin.planete_ready_to_grab.planete_arrimee:
		if grapin.planete_ready_to_grab.is_in_group("planete-grosse"):
			base_offset = Vector3(0, 0, 30) 
			return
		if grapin.planete_ready_to_grab.is_in_group("planete-petite"):
			base_offset = Vector3(0, 0, 8) 
			return
	
	## Retour distance de la caméra de base quyand rien n'est accroché
	base_offset = Vector3(0, 0, 5) 
			
func return_to_base_offset(delta: float) -> void:
		offset = lerp(offset, base_offset, 4.0 * delta) 
		camera.fov = lerp(camera.fov, 90.0, 2.0 * delta)
