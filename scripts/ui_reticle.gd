extends CenterContainer

@export var dot_radius : float = 2.0
@onready var ship : RigidBody3D = $"../../Ship"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if ship.light_mode_state == true:
		visible = true
	else:
		visible = false

func _draw() -> void:
	draw_circle(Vector2(0,0), dot_radius, Color.WHITE)
