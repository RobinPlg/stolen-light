extends Node3D

@export var smooth_speed: float = 20.0
@export var turn_rate: float = 150.0
@export var mouse_sensitivity: float = 0.05

@onready var ship: Node3D = $".."

var mouse_input: Vector2 = Vector2()
var current_rotation: Vector3 = Vector3()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if ship.planete_arrimee: 
		current_rotation.y = 0
		current_rotation.x = 0
		
	else:
		var look_input := Input.get_vector("view_right", "view_left", "view_down", "view_up")
		look_input = turn_rate * look_input * delta
		current_rotation.y += look_input.x
		current_rotation.x += look_input.y
		current_rotation.x = clampf(current_rotation.x, -90, 90)

		look_input += mouse_input
		mouse_input = Vector2()

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		current_rotation.y -= event.relative.x * mouse_sensitivity
		current_rotation.x -= event.relative.y * mouse_sensitivity
		current_rotation.x = clampf(current_rotation.x, -90, 90)
		
		
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_camera_rotation() -> Vector3:
	return current_rotation
