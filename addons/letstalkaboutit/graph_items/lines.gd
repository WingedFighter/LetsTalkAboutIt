@tool
extends GraphNode
class_name Lines

@export var id: String = "0"
@export var lines: Array[String] = ["", "", ""]

func _enter_tree() -> void:
    $ID/LineEdit.text_changed.connect(id_change)
    $Line0/LineEdit.text_changed.connect(set_line0_content)
    $Line1/LineEdit.text_changed.connect(set_line1_content)
    $Line2/LineEdit.text_changed.connect(set_line2_content)

func update_connections() -> void:
    if get_parent() && get_parent() is GraphEdit:
        for connection in get_parent().get_connection_list():
            if connection.from_node == name:
                var to_node = get_graph_element_from_name(connection.to_node)
                if to_node is ConversationMessage:
                    to_node.set_line_id(id)

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

func set_all_lines(p_lines: Array[String]) -> void:
    var index = 0
    for line in p_lines:
        if line.length() > 70:
            index += 1
            continue
        set_line_with_index(index, line)
        index += 1

func set_line_with_index(index: int, new_text: String) -> void:
    match(index):
        0:
            set_line0_content(new_text)
        1:
            set_line1_content(new_text)
        2:
            set_line2_content(new_text)

func set_line0_content(new_text: String) -> void:
    lines[0] = new_text
    if $Line0/LineEdit.text != new_text:
        $Line0/LineEdit.text = new_text

func set_line1_content(new_text: String) -> void:
    lines[1] = new_text
    if $Line1/LineEdit.text != new_text:
        $Line1/LineEdit.text = new_text

func set_line2_content(new_text: String) -> void:
    lines[2] = new_text
    if $Line2/LineEdit.text != new_text:
        $Line2/LineEdit.text = new_text