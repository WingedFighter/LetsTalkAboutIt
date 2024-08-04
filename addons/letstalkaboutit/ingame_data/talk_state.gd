extends Resource
class_name TalkState

@export var current_talk: String
@export var flags: Dictionary

func _init(p_current_talk: String = "0", p_flags = {}) -> void:
    current_talk = p_current_talk
    flags = p_flags

func add_flag(flag_name: String, flag_value: bool = false) -> void:
    set_flag(flag_name, flag_value)

func get_flag(flag_name: String) -> bool:
    return flags[flag_name] == "true"

func set_flag(flag_name: String, flag_value: bool) -> void:
    flags[flag_name] = str(flag_value)

func has_flag(flag_name: String) -> bool:
    return flags.has(flag_name)