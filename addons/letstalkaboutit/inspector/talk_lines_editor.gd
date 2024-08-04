extends EditorProperty
class_name TalkLinesEditor

var current_value: TalkLinesResource

var updating = false

func _init() -> void:
	current_value = TalkLinesResource.new()
	current_value.changed.connect(make_vbox)

func _enter_tree() -> void:
	make_vbox()

func make_vbox() -> void:
	if has_node("TalkLines_List"):
		get_node("TalkLines_List").free()
	var vbox = VBoxContainer.new()
	add_child(vbox)
	vbox.name = "TalkLines_List"
	for index in current_value.lines.size():
		make_hbox(index, vbox)
	set_bottom_editor(vbox)
	refresh_control_text()

func make_hbox(index: int, vbox: VBoxContainer) -> void:
	var hbox = VBoxContainer.new()
	vbox.add_child(hbox)
	hbox.name = "TalkLines_EditLine" + str(index)
	var line_edit = LineEdit.new()
	hbox.add_child(line_edit)
	line_edit.name = "LineEdit"
	line_edit.max_length = 70
	line_edit.text_changed.connect(on_text_submitted.bind(index))

func on_text_submitted(new_text: String, line_index: int) -> void:
	if updating:
		return
	current_value.lines[line_index] = new_text
	emit_changed(get_edited_property(), current_value.lines)

func _update_property() -> void:
	var new_value = get_edited_object()[get_edited_property()]
	if new_value == current_value.lines:
		return
	
	updating = true
	current_value.lines = new_value
	refresh_control_text()
	updating = false

func refresh_control_text() -> void:
	var vbox = get_node("TalkLines_List")
	for index in current_value.lines.size():
		vbox.get_node("TalkLines_EditLine" + str(index)).get_node("LineEdit").text = current_value.lines[index]
