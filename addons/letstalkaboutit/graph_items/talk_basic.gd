@tool
extends GraphNode
class_name TalkBasic

@export var id: String = "0"
@export var messages: String = "-1"
@export var next_id: String = "-1"
@export var end: bool = false

func _enter_tree() -> void:
	$End/CheckBox.toggled.connect(set_end_state)
	id = generate_id()

func generate_id() -> String:
	var id_num = RandomNumberGenerator.new().randi_range(1, 10000)
	var new_id = "TalkBasic_" + str(id_num)
	var graph = get_parent()
	if graph && graph is GraphEdit:
		for child in graph.get_children():
			if child is TalkBasic && child.id == new_id:
				id_num += 1
				new_id = "TalkBasic_" + str(id_num)
	return new_id

func set_messages(message_list_id: String) -> void:
	messages = message_list_id

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id

func set_end_state(toggled_on: bool) -> void:
	end = toggled_on
	if $End/CheckBox.button_pressed != end:
		$End/CheckBox.set_pressed_no_signal(end)