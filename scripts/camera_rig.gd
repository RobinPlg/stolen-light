extends SpringArm3D

@onready var camera: Camera3D = $Camera3D
@onready var grapin: Node3D = $"../Ship/Grapin/GrapinZone"
@onready var ship: RigidBody3D = $"../Ship"

@export var turn_rate:= 150
@export var mouse_sensitivity:= 0.05

var mouse_input: Vector2 = Vector2()
var base_springarm_length: float = 5.0
var target_springarm_length: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_transform.origin = ship.global_transform.origin
	var look_input:= Input.get_vector( "view_right", "view_left", "view_down", "view_up")
	look_input = turn_rate * look_input * delta
	look_input += mouse_input
	mouse_input = Vector2()
	
	rotation_degrees.x += look_input.y
	rotation_degrees.y += look_input.x
	rotation_degrees.x = clampf(rotation_degrees.x, -90, 90)
	
	if Input.is_action_pressed("throttle_up"):
		target_springarm_length = base_springarm_length + 5.0
	if Input.is_action_pressed("throttle_down"):
		target_springarm_length = base_springarm_length
	if Input.is_action_pressed("stabilize"):
		target_springarm_length = base_springarm_length - 1.0
	if Input.is_action_just_released("stabilize") or Input.is_action_just_released("throttle_down") or Input.is_action_just_released("throttle_up"):
		target_springarm_length = base_springarm_length
	
	spring_length = lerp(spring_length, target_springarm_length, 4.0 * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = -event.relative * mouse_sensitivity
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_G and event.pressed:
		target_springarm_length = base_springarm_length + 5.0
		print(spring_length)
	if event is InputEventKey and event.keycode == KEY_H and event.pressed:
		target_springarm_length = base_springarm_length 
		
