@tool
extends GraphNode
class_name TalkBasic

@export var id: String = "0":
	set(value):
		id = value
		if id != "0":
			update_connections()

@export var message_list: Array[String] = []
@export var next_id: String = "-1"

func _enter_tree() -> void:
	$Add.pressed.connect(add_new_message)
	id = name
	call_deferred("reset_size")

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

func reset_message_connections() -> void:
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.to_node == name:
				var from_node = get_graph_element_from_name(connection.from_node)
				if from_node is TalkMessage:
					get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
					get_parent().connect_node(connection.from_node, connection.from_port, connection.to_node, message_list.find(from_node.id))

func delete_message(message_id: String) -> void:
	# Find the index (also the output port number)
	var m_index = message_list.find(message_id)

	# Remove from lists
	message_list.remove_at(m_index)
	# Delete Node
	get_node("Message" + message_id).queue_free()

	# Reset Connections
	reset_message_connections()

	# Reset Choice Labels (0-n)
	var index = 0
	for message in message_list:
		get_node("Message" + message).get_node("Label").text = str(index)
		index += 1
	get_node("MessageTemplate").get_node("Label").text = str(index)

	# Reset Node Size
	call_deferred("reset_size")

func add_new_message(message_id: String = "-1") -> void:
	var index = message_list.size()
	var new_name = str(RandomNumberGenerator.new().randi_range(1, 10000))
	if message_id == "-1":
		var exists = true
		while(exists):
			if message_list.find(new_name) == -1:
				exists = false
			else:
				new_name = str(int(new_name) + 1)
	else:
		new_name = message_id
	message_list.append(new_name)

	# Old Hbox
	var hbox = get_child(get_child_count() - 1)
	hbox.visible = true
	hbox.name = "Message" + message_list[index]
	hbox.get_node("Delete").disabled = false
	hbox.get_node("Delete").pressed.connect(delete_message.bind(message_list[index]))

	# New Hbox
	var new_hbox = hbox.duplicate()
	add_child(new_hbox)
	new_hbox.name = "MessageTemplate"
	new_hbox.visible = false
	new_hbox.get_node("Label").text = str(message_list.size())

	# Setup slots
	set_slot(message_list.size() + 1, true, 2, Color(0.0, 1.0, 1.0), false, 0, Color(1.0, 1.0, 1.0))
	call_deferred("reset_size")

func set_message(message_id: String, index: int) -> void:
	var old_name = message_list[index - 1]
	var hbox = get_node("Message" + old_name)
	hbox.name = "Message" + message_id
	message_list[index - 1] = message_id

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id

func reset_size() -> void:
	if is_inside_tree():
		resizable = true
		await get_tree().process_frame
		resize_request.emit(get_minimum_size())
		await get_tree().process_frame
		resizable = false