extends Node3D

@onready var dialogue_ui := get_tree().current_scene.get_node("dialogue_ui/canvas")
@onready var dialogue_animation: AnimationPlayer = get_tree().current_scene.get_node("dialogue_ui/canvas/AnimationPlayer")
@onready var dialogue_text: RichTextLabel = get_tree().current_scene.get_node("dialogue_ui/canvas/dialogue_text")
@onready var ship: Node3D = get_tree().current_scene.get_node("Ship")
@onready var rotation_cam: Node3D = get_tree().current_scene.get_node("Ship/NodeCamera3D")
@onready var main_camera: Node3D = get_tree().current_scene.get_node("Ship/NodeCamera3D/PositionCamera3D/MainCamera")
@onready var planet: Node3D = $"../"

enum TriggerType { INTERACTION, PROXIMITY, STORY_FLAG, SEQUENCE }

@export var trigger_type: TriggerType = TriggerType.INTERACTION
@export var detection_radius: float
@export var cam_on_ship: bool = false
@export var chat_icon: Node3D
@export var camera_changes: Array[CameraChange] = []

@export_category("Ease")
@export var ease_in: bool = true
@export var ease_out: bool = true
@export var ease_in_speed : float
@export var ease_out_speed := 2.0

@export_category("Dialogue")
@export var flags_required: Array[String] = []
@export var flags_to_set: Array[String] = []
@export var delete_flags: Array[String] = []
@export var dialogues: Array[String]

var camera_dialogue: Node3D
var current_dialogue := -1
var dialogue_started := false
var in_range := false
var dialogue_finished := false
var cinematic_camera_active := false

func _ready() -> void:
	if cam_on_ship:
		camera_dialogue = get_tree().current_scene.get_node("Ship/camera_dialogue_ship")
		$trigger/collision.shape.radius = detection_radius

func _physics_process(_delta: float) -> void:
	match trigger_type:
		TriggerType.INTERACTION:
			if planet.ship == ship:
				chat_icon.visible = false
			if Input.is_action_just_pressed("interaction"):
				if not dialogue_finished and not dialogue_started and in_range:
					start_dialogue()
				elif dialogue_started and not dialogue_finished:
					continue_dialogue()
		TriggerType.PROXIMITY:
			if not dialogue_finished and not dialogue_started and in_range:
				start_dialogue()
			elif dialogue_started and not dialogue_finished:
				if Input.is_action_just_pressed("interaction"):
					continue_dialogue()
					
func can_trigger() -> bool:
	for flag in flags_required:
		if not GameState.has_flag(flag):
			return false
	return true

func start_dialogue() -> void:
	if not can_trigger():
		return
	if ease_in:
		CameraTransition.transition_camera3D(main_camera, camera_dialogue, ease_in_speed)
	else:
		camera_dialogue.current = true
	GameState.player_can_input = false
	ship.forward_speed = 0.0
	dialogue_started = true
	dialogue_ui.visible = true
	if chat_icon != null:
		chat_icon.visible = false
	continue_dialogue()

func end_dialogue() -> void:
	for flag in flags_to_set:
		GameState.set_flag(flag)
	for flag in delete_flags:
		GameState.flags.erase(flag)
	if CameraTransition.transitioning:
		return
	dialogue_ui.visible = false
	dialogue_started = false
	dialogue_finished = true
	current_dialogue = -1
	if ease_out:
		await CameraTransition.transition_camera3D(camera_dialogue, main_camera, ease_out_speed)
	else:
		main_camera.current = true
	GameState.player_can_input = true

func continue_dialogue() -> void:
	current_dialogue += 1
	if current_dialogue < dialogues.size():
		dialogue_text.text = dialogues[current_dialogue]
		dialogue_animation.play("RESET")
		dialogue_animation.play("scroll")
		_check_camera_change(current_dialogue)
	else:
		end_dialogue()

func _check_camera_change(index: int) -> void:
	for change in camera_changes:
		if change.dialogue_index == index:
			var target_camera := get_node(change.camera_path) as Camera3D
			if is_instance_valid(target_camera):
				CameraTransition.transition_camera3D(
					CameraTransition.camera3D,
					target_camera,
					change.transition_duration
				)
				cinematic_camera_active = true
			return
	# Aucune règle pour cet index — retour à camera_dialogue si on était en cinématique
	if cinematic_camera_active:
		CameraTransition.transition_camera3D(
			CameraTransition.camera3D,
			camera_dialogue,
			1.0
		)
		cinematic_camera_active = false

func _on_body_entered(body: Node3D) -> void:
	if body == ship and not dialogue_finished:
		in_range = true
		if chat_icon != null and planet.ship == null:
			chat_icon.visible = trigger_type == TriggerType.INTERACTION

func _on_body_exited(body: Node3D) -> void:
	if body == ship:
		in_range = false
		if chat_icon != null:
			chat_icon.visible = false
