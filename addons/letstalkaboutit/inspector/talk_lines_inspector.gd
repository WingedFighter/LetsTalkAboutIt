extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
    return true

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if type == TYPE_ARRAY && name == "lines":
        add_property_editor(name, TalkLinesEditor.new())
        return true
    if type == TYPE_DICTIONARY && name == "lines_list":
        add_property_editor(name, TalkListEditor.new())
        return true
    return false