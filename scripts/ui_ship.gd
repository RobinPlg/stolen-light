extends Control

@export var ship: Node3D
@export var speedometer: Label
var speed : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	speed = ship.forward_speed
	speedometer.text = str(int(speed), " u/s") 
