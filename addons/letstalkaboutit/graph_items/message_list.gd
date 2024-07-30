@tool
extends GraphNode
class_name MessageList

@export var id: String = "0"
@export var message_list: Array[String] = []

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)

func id_change(new_text: String):
	id = new_text
	if $ID/LineEdit.text != new_text:
		$ID/LineEdit.text = new_text

func delete_message(message_id: String) -> void:
	for m in message_list:
		if m == message_id:
			m = "-1"

func add_new_message(message_id: String) -> void:
	message_list.append(message_id)
	var new_message = $Message0.duplicate()
	add_child(new_message)
	new_message.get_child(1).text = str(message_list.size())
	set_slot(message_list.size() + 1, true, 2, Color(0.0, 1.0, 1.0), false, 0, Color.WHITE)