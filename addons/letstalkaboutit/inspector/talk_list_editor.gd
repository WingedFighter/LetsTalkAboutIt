extends EditorProperty
class_name TalkListEditor

var current_value: TalkListResource

var updating = false

func _init() -> void:
	current_value = TalkListResource.new()
	current_value.changed.connect(make_vbox)

func _enter_tree() -> void:
	make_vbox()

func make_vbox() -> void:
	if has_node("TalkLines_List"):
		get_node("TalkLines_List").free()
	var vbox = VBoxContainer.new()
	add_child(vbox)
	vbox.name = "TalkLines_List"
	var index = 0
	for key in current_value.lines_list:
		make_hbox(index, vbox, key)
		index += 1
	refresh_control_text()
	set_bottom_editor(vbox)

func make_hbox(index: int, vbox: VBoxContainer, key: String) -> void:
	var hbox = VBoxContainer.new()
	var label = Label.new()
	label.name = "Choice" + key
	label.text = "Choice " + str(index)
	vbox.add_child(label)
	vbox.add_child(hbox)
	hbox.name = "TalkLines_EditLine" + key
	var line_edit = LineEdit.new()
	hbox.add_child(line_edit)
	line_edit.name = "LineEdit"
	line_edit.max_length = 70
	line_edit.text_changed.connect(on_text_submitted.bind(key))

func on_text_submitted(new_text: String, key: String) -> void:
	if updating:
		return
	current_value.lines_list[key] = new_text
	emit_changed(get_edited_property(), current_value.lines_list)

func _update_property() -> void:
	var new_value = get_edited_object()[get_edited_property()]
	if new_value == current_value.lines_list:
		return
	
	updating = true
	current_value.lines_list = new_value
	make_vbox()
	refresh_control_text()
	updating = false

func refresh_control_text() -> void:
	var vbox = get_node("TalkLines_List")
	for key in current_value.lines_list:
		if !vbox.has_node("TalkLines_EditLine" + key):
			continue
		vbox.get_node("TalkLines_EditLine" + key).get_node("LineEdit").text = current_value.lines_list[key]
