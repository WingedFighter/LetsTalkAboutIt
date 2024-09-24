@tool
extends GraphNode
class_name TalkMessage

@export var id: String = "0":
	set(value):
		id = value
		if id != "0":
			update_connections()

@export var line_id: String = "-1"
@export var line_resource: TalkLinesResource = TalkLinesResource.new()
@export var character_id: String = "-1"
@export var overlay: String = "none"
@export var background: String = "none"

func _enter_tree() -> void:
	id = name
	$Character/LineEdit.text_changed.connect(set_character_id)
	$Character/LineEdit.text = character_id
	$Overlay/LineEdit.text_changed.connect(set_overlay)
	$Overlay/LineEdit.text = overlay
	$Background/LineEdit.text_changed.connect(set_background)
	$Background/LineEdit.text = background

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
				if to_node is TalkBasic:
					to_node.udpate_existing_message(connection.to_port, id)

func set_line_id(p_line_id: String) -> void:
	line_id = p_line_id

func set_character_id(new_text: String) -> void:
	character_id = new_text

func set_overlay(p_overlay: String) -> void:
	overlay = p_overlay
	if $Overlay/LineEdit.text != overlay:
		$Overlay/LineEdit.text = overlay

func set_lines(p_lines: Array[String]) -> void:
	line_resource.lines = p_lines

func set_background(p_background: String) -> void:
	background = p_background