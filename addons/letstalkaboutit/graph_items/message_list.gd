@tool
extends GraphNode
class_name MessageList

@export var id: String = "0"
@export var message_list: Array[String] = []

var list_size: int = 0

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
			if connection.from_node == name:
				var to_node = get_graph_element_from_name(connection.to_node)
				if to_node is Conversation:
					to_node.set_messages(id)

func reset_message_connections() -> void:
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.to_node == name:
				var from_node = get_graph_element_from_name(connection.from_node)
				if from_node is ConversationMessage:
					get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
					get_parent().connect_node(connection.from_node, connection.from_port, connection.to_node, message_list.find(from_node.id))

# Finish fixing deletion of message from list
func delete_message(message_id: String) -> void:
	message_list.remove_at(message_list.find(message_id))
	get_node("Message" + message_id).queue_free()
	reset_message_connections()
	var index = 0
	for message in message_list:
		get_node("Message" + message).get_node("Label").text = str(index)
		index += 1
	get_node("MessageTemplate").get_node("Label").text = str(index)
	get_node("MessageTemplate").get_node("Label").size = Vector2.ZERO
	resizable = true
	await get_tree().process_frame
	resize_request.emit(get_minimum_size())
	await get_tree().process_frame
	resizable = false

func add_new_message(message_id: String) -> void:
	var index = message_list.size()
	message_list.append(message_id)

	# Old Hbox
	var hbox = get_child(get_child_count() - 1)
	hbox.name = "Message" + message_id

	# New Hbox
	var new_hbox = hbox.duplicate()
	add_child(new_hbox)
	new_hbox.name = "MessageTemplate"
	new_hbox.get_node("Label").text = str(message_list.size())

	# Setup new slot
	set_slot(message_list.size() + 1, true, 2, Color(0.0, 1.0, 1.0), false, 0, Color.WHITE)

func udpate_existing_message(index: int, message_id: String) -> void:
	if index < message_list.size():
		message_list[index] = message_id
	
func create_message_hbox(index: String, message_id: String) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	add_child(hbox)
	hbox.name = "Message" + message_id
	hbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 0.0)
	var spacer = Control.new()
	hbox.add_child(spacer)
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label = Label.new()
	hbox.add_child(label)
	label.text = index
	var spacer_2 = spacer.duplicate()
	hbox.add_child(spacer_2)
	spacer_2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return hbox