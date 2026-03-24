extends Node3D

@onready var dialogue_ui := get_tree().current_scene.get_node("dialogue_ui/canvas")
@onready var dialogue_animation : AnimationPlayer = get_tree().current_scene.get_node("dialogue_ui/canvas/AnimationPlayer")
@onready var dialogue_text: RichTextLabel = get_tree().current_scene.get_node("dialogue_ui/canvas/dialogue_text")
@onready var ship: Node3D = get_tree().current_scene.get_node("Ship")

@export var dialogues: Array[String]

var current_dialogue := -1
var started := false
var in_range := false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interaction"):
		if not started and in_range:
			start_dialogue()
		elif started:
			continue_dialogue()
		
func start_dialogue () -> void:
	print("started")
	started = true
	dialogue_ui.visible = true
	continue_dialogue()


func end_dialogue() -> void:
	dialogue_ui.visible = false
	started = false
	current_dialogue = -1

func continue_dialogue() -> void:
	current_dialogue += 1
	if current_dialogue < dialogues.size():
		dialogue_text.text = dialogues[current_dialogue]
		dialogue_animation.play("RESET")
		dialogue_animation.play("scroll")
	else:
		end_dialogue()


func _on_body_entered(body: Node3D) -> void:
	if body == ship:
		in_range = true


func _on_body_exited(body: Node3D) -> void:
	if body == ship:
		in_range = false
		if started:
			end_dialogue()
