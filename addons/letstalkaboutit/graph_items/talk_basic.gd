@tool
extends GraphNode
class_name TalkBasic

@export var id: String = "0":
	set(value):
		id = value
		if id != "0":
			update_connections()

@export var messages: String = "-1"
@export var next_id: String = "-1"

func _enter_tree() -> void:
	id = name

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

func set_messages(message_list_id: String) -> void:
	messages = message_list_id

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id