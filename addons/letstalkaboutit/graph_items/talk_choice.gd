@tool
extends GraphNode
class_name TalkChoice

@export var id: String = "0":
	set(value):
		id = value
		if id != "0":
			update_connections()

@export var choice_list: Array[String] = []
@export var line_list_resource: TalkListResource = TalkListResource.new()
@export var next_id_list: Dictionary = {}

func _enter_tree() -> void:
	line_list_resource.resource_local_to_scene = true
	$Add.pressed.connect(add_new_choice)
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

func reset_choice_connections() -> void:
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.from_node == name:
				var to_node = get_graph_element_from_name(connection.to_node)
				if to_node is TalkBasic || to_node is TalkChoice || to_node is TalkBranch || to_node is TalkSetFlag || to_node is TalkEnd:
					get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
					get_parent().connect_node(connection.from_node, choice_list.find(next_id_list.find_key(to_node.id)), connection.to_node, connection.to_port)

func delete_choice(choice_id: String) -> void:
	# Find the index (also the output port number)
	var c_index = choice_list.find(choice_id)

	# Remove from lists
	choice_list.remove_at(c_index)
	line_list_resource.lines_list.erase(choice_id)
	next_id_list.erase(choice_id)

	# Delete related connection, if it exists
	if get_parent() && get_parent() is GraphEdit:
		for connection in get_parent().get_connection_list():
			if connection.from_node == name:
				var to_node = get_graph_element_from_name(connection.to_node)
				if to_node is TalkBasic || to_node is TalkChoice || to_node is TalkBranch || to_node is TalkSetFlag:
					if connection.from_port == c_index:
						get_parent().disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)

	# Delete Node
	get_node("Choice" + choice_id).queue_free()

	# Reset Connections
	reset_choice_connections()

	# Reset Choice Labels (0-n)
	var index = 0
	for choice in choice_list:
		get_node("Choice" + choice).get_node("Label").text = str(index)
		index += 1
	get_node("ChoiceTemplate").get_node("Label").text = str(index)

	# Notify inspector of change
	line_list_resource.notify_property_list_changed()

	# Reset Node Size
	call_deferred("reset_size")

func reset_size() -> void:
	if is_inside_tree():
		resizable = true
		await get_tree().process_frame
		resize_request.emit(get_minimum_size())
		await get_tree().process_frame
		resizable = false

func add_new_choice(choice_id: String = "-1") -> void:
	var index = choice_list.size()
	var new_name = str(RandomNumberGenerator.new().randi_range(1, 10000))
	if choice_id == "-1":
		var exists = true
		while(exists):
			if choice_list.find(new_name) == -1:
				exists = false
			else:
				new_name = str(int(new_name) + 1)
	else:
		new_name = choice_id
	choice_list.append(new_name)

	# Old Hbox
	var hbox = get_child(get_child_count() - 1)
	hbox.visible = true
	hbox.name = "Choice" + choice_list[index]
	hbox.get_node("Delete").disabled = false
	hbox.get_node("Delete").pressed.connect(delete_choice.bind(choice_list[index]))

	# New Hbox
	var new_hbox = hbox.duplicate()
	add_child(new_hbox)
	new_hbox.name = "ChoiceTemplate"
	new_hbox.visible = false
	new_hbox.get_node("Label").text = str(choice_list.size())

	line_list_resource.lines_list[new_name] = ""
	line_list_resource.notify_property_list_changed()

	# Setup slots
	set_slot(choice_list.size(), false, 0, Color(1.0, 1.0, 1.0), true, 0, Color(1.0, 1.0, 1.0))
	call_deferred("reset_size")

func check_choice_set(port: int) -> bool:
	return next_id_list[choice_list[port]] != "-1"

func set_next_id(next_id: String, port: int) -> void:
	next_id_list[choice_list[port]] = next_id