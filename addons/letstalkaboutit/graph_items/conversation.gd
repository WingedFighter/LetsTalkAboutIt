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

func id_change(new_text: String):
    id = new_text
    if $ID/LineEdit.text != new_text:
        $ID/LineEdit.text = new_text

func set_messages(message_list_id: String) -> void:
    messages = message_list_id

func set_output_value(out_port: int, to_child: Node) -> void:
    if get_output_port_slot(out_port) == 1:
        if !to_child:
            next_id = "-1"
            $NextID/LineEdit.text = "-1"
            $NextID/LineEdit.editable = true
        elif to_child is Conversation:
            next_id = to_child.id
            $NextID/LineEdit.text = to_child.id
            $NextID/LineEdit.editable = false

func set_end_state(toggled_on: bool) -> void:
    end = toggled_on
    if $End/CheckBox.button_pressed != end:
        $End/CheckBox.set_pressed_no_signal(end)