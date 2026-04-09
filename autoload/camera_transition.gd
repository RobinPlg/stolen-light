extends Node

@onready var camera3D: Camera3D = $Camera3D
var transitioning: bool = false
var _original_parent: Node
var _target_camera: Camera3D = null
var _progress: float = 0.0
var _duration: float = 2.0
var _from_transform: Transform3D
var _from_fov: float
var _on_complete_callback: Callable

signal _completed

func _ready() -> void:
	_original_parent = camera3D.get_parent()

func _process(delta: float) -> void:
	if not transitioning or _target_camera == null:
		return
	
	_progress += delta / _duration
	_progress = clamp(_progress, 0.0, 1.0)
	
	var t := _ease_in_out_cubic(_progress)
	
	camera3D.global_transform = _from_transform.interpolate_with(
		_target_camera.global_transform, t
	)
	camera3D.fov = lerpf(_from_fov, _target_camera.fov, t)
	
	if _progress >= 1.0:
		_on_transition_complete()

func _ease_in_out_cubic(x: float) -> float:
	if x < 0.5:
		return 4.0 * x * x * x
	else:
		return 1.0 - pow(-2.0 * x + 2.0, 3.0) / 2.0

func _on_transition_complete() -> void:
	transitioning = false
	if _on_complete_callback:
		_on_complete_callback.call()
		_on_complete_callback = Callable()
	_completed.emit()

func _wait_for_completion() -> void:
	await _completed

func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if transitioning:
		return
	
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	camera3D.global_transform = from.global_transform
	camera3D.current = true
	
	_from_transform = from.global_transform
	_from_fov = from.fov
	_target_camera = to
	_duration = duration
	_progress = 0.0
	transitioning = true
	
	_on_complete_callback = func() ->void:
		_original_parent = camera3D.get_parent()
		camera3D.reparent(to.get_parent(), true)
		camera3D.transform = to.transform
		_target_camera = null
	
	await _wait_for_completion()
