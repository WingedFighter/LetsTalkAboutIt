extends Resource
class_name NodeData

@export var name: String
@export var type: String
@export var position_offset: Vector2
@export var data: Dictionary

func _init(p_name: String = "", p_type: String = "GraphNode",
            p_offset = Vector2.ZERO, p_data: Dictionary = {}) -> void:
    name = p_name
    type = p_type
    position_offset = p_offset
    data = p_data