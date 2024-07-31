@tool
extends GraphNode
class_name Conversation

@export var id: String = "0"
@export var messages: String = "-1"
@export var next_id: String = "-1"
@export var end: bool = false

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)
	$End/CheckBox.toggled.connect(set_end_state)

func id_change(new_text: String) -> void:
	id = new_text
	if $ID/LineEdit.text != new_text:
		$ID/LineEdit.text = new_text
	update_connections()

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
				if from_node is Conversation:
					from_node.set_next_id(id)
				if from_node is ConversationChoice:
					from_node.set_next_id(id, connection.from_port)

func set_messages(message_list_id: String) -> void:
	messages = message_list_id

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id
	$NextID/LineEdit.text = next_id
	$NextID/LineEdit.editable = p_next_id == "-1"

func set_end_state(toggled_on: bool) -> void:
	end = toggled_on
	if $End/CheckBox.button_pressed != end:
		$End/CheckBox.set_pressed_no_signal(end)