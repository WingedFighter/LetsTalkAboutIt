extends Resource
class_name TalkLinesResource

@export var lines: Array[String] = ["", "", ""]

func _init(p_lines: Array[String] = ["", "", ""]) -> void:
    lines = p_lines