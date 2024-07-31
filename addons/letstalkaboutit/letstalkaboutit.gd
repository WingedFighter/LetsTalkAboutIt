@tool
extends EditorPlugin

const ConversationPanel: PackedScene = preload("res://addons/letstalkaboutit/main_screen/main_screen_convo_node.tscn")
const Conversation: PackedScene = preload("res://addons/letstalkaboutit/graph_items/conversation.tscn")
const ConversationBranch: PackedScene = preload("res://addons/letstalkaboutit/graph_items/conversation_branch.tscn")
const MessageList: PackedScene = preload("res://addons/letstalkaboutit/graph_items/message_list.tscn")
const ConversationMessage: PackedScene = preload("res://addons/letstalkaboutit/graph_items/message.tscn")
const Lines: PackedScene = preload("res://addons/letstalkaboutit/graph_items/lines.tscn")
const ConversationChoice: PackedScene = preload("res://addons/letstalkaboutit/graph_items/conversation_choice.tscn")
const ConversationManager: Script = preload("res://addons/letstalkaboutit/nodes/conversation_manager.gd")

var icon = preload("res://icon.svg")

var graph_types = {
	"Conversation": Conversation,
	"ConversationBranch": ConversationBranch,
	"MessageList": MessageList,
	"ConversationMessage": ConversationMessage,
	"Lines": Lines,
	"ConversationChoice": ConversationChoice
}

var conversation_panel

func _enter_tree() -> void:
	add_custom_type("ConversationManager", "Node", ConversationManager, icon)

func _handles(object: Object) -> bool:
	return object is ConversationManager

func _make_visible(visible: bool) -> void:
	if visible:
		add_conversation_panel()
	else:
		remove_conversation_panel()

func _edit(object: Object) -> void:
	if object && object is ConversationManager:
		conversation_panel.load_conversation_manager(object)

func _exit_tree() -> void:
	remove_conversation_panel()
	queue_free()

func add_conversation_panel() -> void:
	if !conversation_panel:
		conversation_panel = ConversationPanel.instantiate()
		conversation_panel.add_types = graph_types
	add_control_to_bottom_panel(conversation_panel, "ConversationManager")

func remove_conversation_panel() -> void:
	if conversation_panel:
		if is_instance_valid(conversation_panel):
			remove_control_from_bottom_panel(conversation_panel)
			conversation_panel.queue_free()