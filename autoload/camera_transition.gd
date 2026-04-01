extends Node

@onready var camera3D: Camera3D = $Camera3D

var transitioning: bool = false
var tween: Tween


func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if transitioning:
		return

	# Copie les paramètres de la caméra source
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask

	# Place la caméra de transition sur la caméra source
	camera3D.global_transform = from.global_transform

	# Active la caméra de transition
	camera3D.current = true
	transitioning = true

	# Annule le tween précédent et en crée un nouveau
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Interpole transform et fov en parallèle
	tween.tween_property(camera3D, "global_transform", to.global_transform, duration)
	tween.parallel().tween_property(camera3D, "fov", to.fov, duration)

	# Attend la fin
	await tween.finished

	# Active la caméra cible et libère la caméra de transition
	to.current = true
	transitioning = false
