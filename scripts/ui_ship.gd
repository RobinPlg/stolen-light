extends Control

@onready var ship: Node3D = $"../Ship"
@onready var speedometer: Label = $speedometer
@onready var planete_logo: TextureRect = $PlaneteLogo
@onready var orbit_logo: TextureRect = $OrbitLogo
@onready var grapin : Node3D = $"../Ship/Grapin/GrapinZone"
var speed : float

func _ready() -> void:
	planete_logo.visible = false
	orbit_logo.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	speed = ship.forward_speed
	speedometer.text = str(int(speed), " u/s") 
	
	if grapin.is_planete_here: 
		planete_logo.visible = true
	else: 
		planete_logo.visible = false
	
	if is_instance_valid(ship.planete_arrimee):
		if ship.planete_arrimee.can_orbit == true:
			orbit_logo.visible = true
		else:
			orbit_logo.visible = false
	else: 
		orbit_logo.visible = false
