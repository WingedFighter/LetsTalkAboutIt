@tool
extends EditorPlugin

# Bottom dock editor panel
const TalkPanel: PackedScene = preload("res://addons/letstalkaboutit/main_screen/main_screen_convo_node.tscn")

# Graph nodes
const TalkBasic: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_basic.tscn")
const TalkBranch: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_branch.tscn")
const TalkMessageList: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_message_list.tscn")
const TalkMessage: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_message.tscn")
const TalkLines: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_lines.tscn")
const TalkChoice: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_choice.tscn")
const TalkSetFlag: PackedScene = preload("res://addons/letstalkaboutit/graph_items/talk_set_flag.tscn")

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

var conversation_panel

func _enter_tree() -> void:
	add_custom_type("TalkManager", "Node", TalkManager, icon)

func _handles(object: Object) -> bool:
	return object is TalkManager

func _make_visible(visible: bool) -> void:
	if visible:
		add_conversation_panel()
	else:
		remove_conversation_panel()

func _edit(object: Object) -> void:
	if object && object is TalkManager:
		conversation_panel.load_conversation_manager(object)

func _exit_tree() -> void:
	remove_conversation_panel()
	queue_free()

func add_conversation_panel() -> void:
	if !conversation_panel:
		conversation_panel = TalkPanel.instantiate()
		conversation_panel.add_types = graph_types
	add_control_to_bottom_panel(conversation_panel, "TalkManager")

func remove_conversation_panel() -> void:
	if conversation_panel:
		if is_instance_valid(conversation_panel):
			remove_control_from_bottom_panel(conversation_panel)
			conversation_panel.queue_free()