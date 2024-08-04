@tool
extends GraphNode
class_name TalkSetFlag

@export var id: String = "0"
@export var next_id: String = "-1"
@export var flag_name: String = "default_flag_name"
@export var flag_value: bool = false

func _enter_tree() -> void:
	$FlagName/LineEdit.text_changed.connect(set_flag_name)
	$FlagValue/CheckBox.toggled.connect(set_flag_value)
	id = generate_id()

func generate_id() -> String:
	var id_num = RandomNumberGenerator.new().randi_range(1, 10000)
	var new_id = "TalkSetFlag_" + str(id_num)
	var graph = get_parent()
	if graph && graph is GraphEdit:
		for child in graph.get_children():
			if child is TalkSetFlag && child.id == new_id:
				id_num += 1
				new_id = "TalkSetFlag_" + str(id_num)
	return new_id

func set_flag_name(new_text: String) -> void:
	flag_name = new_text
	if $FlagName/LineEdit.text != new_text:
		$FlagName/LineEdit.text = new_text

func set_next_id(p_next_id: String) -> void:
	next_id = p_next_id

func set_flag_value(toggled_on: bool) -> void:
	flag_value = toggled_on
	if $FlagValue/CheckBox.button_pressed != flag_value:
		$FlagValue/CheckBox.set_pressed_no_signal(flag_value)