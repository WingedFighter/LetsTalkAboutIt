@tool
extends GraphNode
class_name TalkStart

@export var id: String = "Start"
@export var next_id: String = "-1"

func _enter_tree() -> void:
	reset_size()

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id

func reset_size() -> void:
	if is_inside_tree():
		resizable = true
		await get_tree().process_frame
		resize_request.emit(get_minimum_size())
		await get_tree().process_frame
		resizable = false