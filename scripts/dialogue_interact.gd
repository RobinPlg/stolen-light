extends Node3D

@onready var dialogue_ui := get_tree().current_scene.get_node("dialogue_ui/canvas")
@onready var dialogue_animation : AnimationPlayer = get_tree().current_scene.get_node("dialogue_ui/canvas/AnimationPlayer")
@onready var dialogue_text: RichTextLabel = get_tree().current_scene.get_node("dialogue_ui/canvas/dialogue_text")
@onready var ship: Node3D = get_tree().current_scene.get_node("Ship")
@onready var chat_icon: Node3D = $"../ChatIcon"
@onready var camera_dialogue: Node3D = $"../Camera3D"
@onready var main_camera: Node3D = get_tree().current_scene.get_node("Ship/NodeCamera3D/PositionCamera3D/MainCamera")

@export var dialogues: Array[String]

var current_dialogue := -1
var started := false
var in_range := false
var finished := false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interaction"):
		if not finished:
			if not started and in_range:
				start_dialogue()
			elif started and not finished:
				continue_dialogue()
			
func start_dialogue () -> void:
	CameraTransition.transition_camera3D(main_camera, camera_dialogue, 2.0) 
	ship.forward_speed = 0.0
	ship.can_move = 0
	started = true
	dialogue_ui.visible = true
	chat_icon.visible = false
	continue_dialogue()

func end_dialogue() -> void:
	if CameraTransition.transitioning == false:
		CameraTransition.transition_camera3D(camera_dialogue, main_camera, 2.0)
		dialogue_ui.visible = false
		started = false
		finished = true
		current_dialogue = -1
		ship.can_move = 1

func continue_dialogue() -> void:
	current_dialogue += 1
	if current_dialogue < dialogues.size():
		dialogue_text.text = dialogues[current_dialogue]
		dialogue_animation.play("RESET")
		dialogue_animation.play("scroll")
	else:
		end_dialogue()


func _on_body_entered(body: Node3D) -> void:
	if body == ship and not finished:
		in_range = true
		chat_icon.visible = true
func _on_body_exited(body: Node3D) -> void:
	if body == ship:
		in_range = false
		chat_icon.visible = false
