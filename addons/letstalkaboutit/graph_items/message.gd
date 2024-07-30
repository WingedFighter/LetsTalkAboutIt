@tool
extends GraphNode
class_name ConversationMessage

@export var id: String = "0"
@export var line_id: String = "-1"
@export var character_id: String = "-1"
@export var expression: Speaker.MOOD = -1

func _enter_tree() -> void:
	$ID/LineEdit.text_changed.connect(id_change)
	for mood in Speaker.MOOD:
		$Expression/OptionButton.add_item(mood, Speaker.MOOD[mood])
	if expression == -1:
		expression = Speaker.MOOD.NEUTRAL
	if $Expression/OptionButton.selected != expression:
		$Expression/OptionButton.select(expression)
	$Expression/OptionButton.item_selected.connect(expression_selected)

func id_change(new_text: String):
	id = new_text
	if $ID/LineEdit.text != new_text:
		$ID/LineEdit.text = new_text

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