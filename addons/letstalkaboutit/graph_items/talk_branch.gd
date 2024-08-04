@tool
extends GraphNode
class_name TalkBranch

@export var id: String = "0"
@export var flag_name: String = "default_flag_name"
@export var true_next_id: String = "-1"
@export var false_next_id: String = "-1"

func _enter_tree() -> void:
	$FlagName/LineEdit.text_changed.connect(set_flag_name)
	id = generate_id()

func generate_id() -> String:
	var id_num = RandomNumberGenerator.new().randi_range(1, 10000)
	var new_id = "TalkBranch_" + str(id_num)
	var graph = get_parent()
	if graph && graph is GraphEdit:
		for child in graph.get_children():
			if child is TalkBranch && child.id == new_id:
				id_num += 1
				new_id = "TalkBranch_" + str(id_num)
	return new_id

func set_flag_name(new_text: String) -> void:
	flag_name = new_text
	if $FlagName/LineEdit.text != new_text:
		$FlagName/LineEdit.text = new_text

func set_next_id(next_id: String, port: int) -> void:
	if port == 0:
		true_next_id = next_id
	else:
		false_next_id = next_id