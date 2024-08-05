@tool
extends GraphNode
class_name TalkStart

@export var id: String = "Start"
@export var next_id: String = "-1"

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id