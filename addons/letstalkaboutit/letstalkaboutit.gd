@tool
extends EditorPlugin

# Bottom dock editor panel
const TalkPanel: PackedScene = preload("res://addons/letstalkaboutit/bottom_dock/talk_editor.tscn")

# Inspector panel
const TalkLinesInspector: Script = preload("res://addons/letstalkaboutit/inspector/talk_lines_inspector.gd")

# Graph nodes
const TalkBasic: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_basic.tscn")
const TalkBranch: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_branch.tscn")
const TalkMessageList: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_message_list.tscn")
const TalkMessage: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_message.tscn")
const TalkLines: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_lines.tscn")
const TalkChoice: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_choice.tscn")
const TalkSetFlag: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_set_flag.tscn")

# Custom Nodes
const TalkManager: Script = preload("res://addons/letstalkaboutit/nodes/talk_manager.gd")

var icon = preload("res://icon.svg")

var graph_types = {
	"TalkBasic": TalkBasic,
	"TalkBranch": TalkBranch,
	"TalkMessageList": TalkMessageList,
	"TalkMessage": TalkMessage,
	"TalkLines": TalkLines,
	"TalkChoice": TalkChoice,
	"TalkSetFlag": TalkSetFlag
}

var talk_panel
var talk_basic_inspector

func _enter_tree() -> void:
	add_custom_type("TalkManager", "Node", TalkManager, icon)
	add_talk_basic_inspector()

func _handles(object: Object) -> bool:
	return object is TalkManager

func _make_visible(visible: bool) -> void:
	if visible:
		add_talk_panel()
	else:
		remove_talk_panel()

func _edit(object: Object) -> void:
	if object && object is TalkManager:
		talk_panel.load_talk_manager(object)

func _exit_tree() -> void:
	remove_talk_panel()
	queue_free()

func add_talk_panel() -> void:
	if !talk_panel:
		talk_panel = TalkPanel.instantiate()
		talk_panel.add_types = graph_types
	add_control_to_bottom_panel(talk_panel, "TalkManager")

func remove_talk_panel() -> void:
	if talk_panel:
		if is_instance_valid(talk_panel):
			remove_control_from_bottom_panel(talk_panel)
			talk_panel.queue_free()

func add_talk_basic_inspector() -> void:
	if !talk_basic_inspector:
		talk_basic_inspector = TalkLinesInspector.new()
	add_inspector_plugin(talk_basic_inspector)

func remove_talk_basic_inspector() -> void:
	if talk_basic_inspector:
		remove_inspector_plugin(talk_basic_inspector)