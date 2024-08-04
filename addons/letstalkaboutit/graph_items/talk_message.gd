@tool
extends GraphNode
class_name TalkMessage

@export var id: String = "0"
@export var line_id: String = "-1"
@export var line_resource: TalkLinesResource = TalkLinesResource.new()
@export var character_id: String = "-1"
@export var expression: Speaker.MOOD = -1

func _enter_tree() -> void:
	$Expression/OptionButton.clear()
	for mood in Speaker.MOOD:
		$Expression/OptionButton.add_item(mood, Speaker.MOOD[mood])
	if expression == -1:
		expression = Speaker.MOOD.NEUTRAL
	if $Expression/OptionButton.selected != expression:
		$Expression/OptionButton.select(expression)
	$Expression/OptionButton.item_selected.connect(expression_selected)
	id = generate_id()

func generate_id() -> String:
	var id_num = RandomNumberGenerator.new().randi_range(1, 10000)
	var new_id = "TalkMessage_" + str(id_num)
	var graph = get_parent()
	if graph && graph is GraphEdit:
		for child in graph.get_children():
			if child is TalkMessage && child.id == new_id:
				id_num += 1
				new_id = "TalkMessage_" + str(id_num)
	return new_id

func set_line_id(p_line_id: String) -> void:
	line_id = p_line_id

func set_character_id(p_character_id: String) -> void:
	character_id = p_character_id

func expression_selected(index: int) -> void:
	expression = Speaker.MOOD[$Expression/OptionButton.get_item_text(index)]

func set_expression(mood: int) -> void:
	expression = mood
	if $Expression/OptionButton.item_count > mood:
		$Expression/OptionButton.select(mood)

func set_lines(p_lines: Array[String]) -> void:
	line_resource.lines = p_lines