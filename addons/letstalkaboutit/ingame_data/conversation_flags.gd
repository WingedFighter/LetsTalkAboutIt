extends Node
class_name ConversationFlags

var flags: Dictionary = {}

func add_flag(flag_name: String, flag_value: bool = false) -> void:
    set_flag(flag_name, flag_value)

func get_flag(flag_name: String) -> bool:
    return bool(flags[flag_name])

func set_flag(flag_name: String, flag_value: bool) -> void:
    flags[flag_name] = str(flag_value)

func has_flag(flag_name: String) -> bool:
    return flags.has(flag_name)