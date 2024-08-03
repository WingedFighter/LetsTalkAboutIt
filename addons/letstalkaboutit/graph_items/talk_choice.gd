@tool
extends GraphNode
class_name TalkChoice

@export var id: String = "0"
@export var choice_list: Array[String] = []
@export var next_id_list: Dictionary = {}

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)

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
				if from_node is TalkBasic || from_node is TalkSetFlag:
					from_node.set_next_id(id)
				if from_node is TalkChoice || from_node is TalkBranch:
					from_node.set_next_id(id, connection.from_port)

func reset_choice_connections() -> void:
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.from_node == name:
				var to_node = get_graph_element_from_name(connection.to_node)
				if to_node is TalkBasic || to_node is TalkChoice || to_node is TalkBranch || to_node is TalkSetFlag:
					get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
					get_parent().connect_node(connection.from_node, choice_list.find(to_node.id), connection.to_node, connection.to_port)
			if connection.to_node == name && connection.to_port > 0:
				var from_node = get_graph_element_from_name(connection.from_node)
				if from_node is TalkBasic || from_node is TalkChoice || from_node is TalkLines || from_node is TalkBranch || from_node is TalkSetFlag:
					get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
					get_parent().connect_node(connection.from_node, connection.from_port, connection.to_node, choice_list.find(from_node.id) + 1)

func delete_choice(choice_id: String) -> void:
	var output_port = choice_list.find(choice_id)
	choice_list.remove_at(output_port)
	next_id_list.erase(choice_id)
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.from_node == name:
				var to_node = get_graph_element_from_name(connection.to_node)
				if to_node is TalkBasic || to_node is TalkChoice || to_node is TalkBranch || to_node is TalkSetFlag:
					if connection.from_port == output_port:
						get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
	get_node("Choice" + choice_id).queue_free()
	reset_choice_connections()
	var index = 0
	for choice in choice_list:
		get_node("Choice" + choice).get_node("Label").text = str(index)
		index += 1
	get_node("ChoiceTemplate").get_node("Label").text = str(index)
	resizable = true
	await get_tree().process_frame
	resize_request.emit(get_minimum_size())
	await get_tree().process_frame
	resizable = false

func add_new_choice(choice_id: String) -> void:
	var index = choice_list.size()
	choice_list.append(choice_id)

	# Old Hbox
	var hbox = get_child(get_child_count() - 1)
	hbox.name = "Choice" + choice_id

	# New Hbox
	var new_hbox = hbox.duplicate()
	add_child(new_hbox)
	new_hbox.name = "ChoiceTemplate"
	new_hbox.get_node("Label").text = str(choice_list.size())

	# Setup slots
	set_slot_enabled_right(choice_list.size(), true)
	set_slot(choice_list.size() + 1, true, 3, Color(1.0, 0.0, 1.0), false, 0, Color(1.0, 1.0, 1.0))

func update_existing_choice(choice_id: String, port: int) -> void:
	if port < choice_list.size() + 1:
		get_node("Choice" + choice_list[port - 1]).name = "Choice" + choice_id
		choice_list[port - 1] = choice_id

func check_choice_set(port: int) -> bool:
	return next_id_list[choice_list[port]] != "-1"

func set_next_id(next_id: String, port: int) -> void:
	next_id_list[choice_list[port]] = next_id
	var l_edit = get_node("Choice" + choice_list[port]).get_node("LineEdit")
	l_edit.text = next_id
	l_edit.editable = next_id == "-1"