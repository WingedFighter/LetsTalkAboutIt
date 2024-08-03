@tool
extends GraphNode
class_name TalkBranch

@export var id: String = "0"
@export var flag_name: String = "default_flag_name"
@export var true_next_id: String = "-1"
@export var false_next_id: String = "-1"

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)
	$FlagName/LineEdit.text_changed.connect(set_flag_name)

func id_change(new_text: String) -> void:
	id = new_text
	if $ID/LineEdit.text != new_text:
		$ID/LineEdit.text = new_text
	update_connections()

func set_flag_name(new_text: String) -> void:
	flag_name = new_text
	if $FlagName/LineEdit.text != new_text:
		$FlagName/LineEdit.text = new_text

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
				if from_node is TalkBasic || from_node is TalkSetFlag:
					from_node.set_next_id(id)
				if from_node is TalkChoice || from_node is TalkBranch:
					from_node.set_next_id(id, connection.from_port)

func set_next_id(next_id: String, port: int) -> void:
	if port == 0:
		true_next_id = next_id
		$TrueID/LineEdit.text = next_id
		$TrueID/LineEdit.editable = next_id == "-1"
	else:
		false_next_id = next_id
		$FalseID/LineEdit.text = next_id
		$FalseID/LineEdit.editable = next_id == "-1"