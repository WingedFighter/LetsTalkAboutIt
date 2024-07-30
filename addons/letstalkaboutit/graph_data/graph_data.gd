extends Resource
class_name GraphData

@export var connections: Array
@export var nodes: Array

func _init(p_connections: Array = [], p_nodes: Array = []) -> void:
    connections = p_connections
    nodes = p_nodes