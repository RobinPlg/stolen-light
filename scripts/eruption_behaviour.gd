extends Node3D

@export_category("Éruption Volcanique")
@export var eruption_torque_strength: float = 50.0
@export var eruption_force_min: float = 0.5
@export var eruption_force_max :float = 2.0
@export var eruption_direction_local: Vector3 = Vector3(0, 1, 0)
@export var eruption_interval_min: float = 5.0
@export var eruption_interval_max: float = 15.0

@onready var particles_sparks := $"../SparksEffect"
@onready var particles_smoke :=$"../SmokeEffect"
@onready var particles_lava := $"../LavaEffect"

@onready var volcan_marker: Node3D = $"../PlaneteMesh/VolcanMarker"
@export var projectile_scene: PackedScene 
@export var projectile_spawn_offset: float = 10.0  # distance du centre de la planète

@onready var eruption_timer: Timer = $EruptionTimer
var planet: RigidBody3D
var random_torque := Vector3.ZERO

func _ready() -> void:
	planet = get_parent() as RigidBody3D
	
	eruption_timer.one_shot = true
	eruption_timer.timeout.connect(_on_eruption)
	_start_timer() 

func _start_timer() -> void:
	eruption_timer.wait_time = randf_range(eruption_interval_min, eruption_interval_max)
	eruption_timer.start()
	
func _on_eruption() -> void:
	if planet == null:
		return
	var world_direction := planet.global_transform.basis * eruption_direction_local.normalized()
	planet.apply_central_impulse(world_direction * randf_range(eruption_force_min,eruption_force_max))
	
	if planet.ship == null:
		random_torque = Vector3(
			randf_range(-1.0, 1.0),
			0,
			randf_range(-1.0, 1.0)
		).normalized() * eruption_torque_strength
	else:
		random_torque = Vector3(
			0,
			0,
			randf_range(-1.0, 1.0)
		)
	planet.apply_torque_impulse(random_torque)
	
	 ## Instanciation du projectile
	#if projectile_scene:
		#var projectile := projectile_scene.instantiate()
		#get_tree().current_scene.add_child(projectile)
		## Spawn à la surface de la planète côté volcan
		#projectile.global_position = volcan_marker.global_position
		## Oriente le projectile dans la direction de l'éruption
		#var launch_direction := volcan_marker.global_transform.basis.y
		## Si ton projectile a une vitesse initiale
		#if projectile.has_method("launch"):
			#projectile.launch(launch_direction)
	
	particles_sparks.restart()
	particles_smoke.restart()
	particles_lava.restart()
	_start_timer() 
