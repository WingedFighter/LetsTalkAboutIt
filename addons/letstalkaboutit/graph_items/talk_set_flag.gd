@tool
extends GraphNode
class_name TalkSetFlag

@export var id: String = "0"
@export var next_id: String = "-1"
@export var flag_name: String = "default_flag_name"
@export var flag_value: bool = false

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)
	$FlagName/LineEdit.text_changed.connect(set_flag_name)
	$FlagValue/CheckBox.toggled.connect(set_flag_value)

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
				if from_node is Conversation || TalkSetFlag:
					from_node.set_next_id(id)
				if from_node is ConversationChoice || from_node is ConversationBranch:
					from_node.set_next_id(id, connection.from_port)

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id
	$NextID/LineEdit.text = next_id
	$NextID/LineEdit.editable = p_next_id == "-1"

func set_flag_value(toggled_on: bool) -> void:
	flag_value = toggled_on
	if $FlagValue/CheckBox.button_pressed != flag_value:
		$FlagValue/CheckBox.set_pressed_no_signal(flag_value)