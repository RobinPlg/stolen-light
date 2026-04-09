extends Node


var flags: Dictionary = {}
var player_can_input: bool = true

func set_flag(flag: String, value: Variant = true) -> void:
	flags[flag] = value
	flag_changed.emit(flag, value)

func get_flag(flag: String, default: Variant = false) -> Variant:
	return flags.get(flag, default)

func has_flag(flag: String) -> bool:
	return flags.get(flag, false)

signal flag_changed(flag: String, value: Variant)
