@tool
extends GraphNode
class_name TalkEnd

@export var id: String = "End":
	set(value):
		id = value
		if id != "End":
			update_connections()

@export var next_start: String = "Start"

func _enter_tree() -> void:
	$End/LineEdit.text_changed.connect(set_next_start)
	$End/LineEdit.text = next_start
	reset_size()

func set_next_start(n_start: String) -> void:
	next_start = n_start
	if $End/LineEdit.text != next_start:
		$End/LineEdit.text = next_start

func get_graph_element_from_name(p_name: StringName) -> GraphNode:
	var graph = get_parent()
	if graph && graph is GraphEdit:
		for child in graph.get_children():
			if child.name == p_name:
				return child
	return

func update_connections() -> void:
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.to_node == name:
				var from_node = get_graph_element_from_name(connection.from_node)
				if from_node is TalkBasic || from_node is TalkSetFlag || from_node is TalkStart:
					from_node.set_next_id(id)
				if from_node is TalkChoice || from_node is TalkBranch:
					from_node.set_next_id(id, connection.from_port)

func reset_size() -> void:
	if is_inside_tree():
		resizable = true
		await get_tree().process_frame
		resize_request.emit(get_minimum_size())
		await get_tree().process_frame
		resizable = false