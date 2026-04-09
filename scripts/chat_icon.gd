extends Node3D

@export var target: Node3D  # assigner la planète dans l'Inspector

func _ready() -> void:
	get_parent().remove_child(self)
	get_tree().current_scene.add_child(self)

func _process(_delta: float) -> void:
	if target == null:
		return
	# Suit uniquement la position, pas la rotation
	global_position = target.global_position
	global_position.y += 12.0
