extends Resource
class_name TalkListResource

@export var lines_list: Dictionary = {}

func _init(p_lines_list = {}) -> void:
    lines_list = p_lines_list