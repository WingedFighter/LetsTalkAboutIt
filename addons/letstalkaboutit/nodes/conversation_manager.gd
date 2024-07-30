extends Node
class_name ConversationManager

@export var graph_data_save_location: String = "res://graph_data.tres"
@export var conversation_state_save_location: String = "res://conversation_state.tres" 

@export var graph_data: GraphData
@export var conversation_state: ConversationState

func _ready() -> void:
	load_graph_data()
	if !conversation_state:
		conversation_state = ConversationState.new()

func set_next_conversation(id: String) -> void:
	conversation_state.current_conversation = id

func load_graph_data() -> void:
	if ResourceLoader.exists(graph_data_save_location):
		var g_data = ResourceLoader.load(graph_data_save_location)
		if g_data is GraphData:
			graph_data = g_data
	
	if !conversation_state:
		if ResourceLoader.exists(conversation_state_save_location):
			var c_data = ResourceLoader.load(conversation_state_save_location)
			if c_data is ConversationState:
				conversation_state = c_data
		else:
			conversation_state = ConversationState.new()

func get_node_by_type_and_id(p_type: String, p_id: String) -> NodeData:
	for node in graph_data.nodes:
		if node.type == p_type:
			if node.data.id == p_id:
				return node
	return

func get_node_by_id(p_id: String) -> NodeData:
	for node in graph_data.nodes:
		if node.data.id == p_id:
			return node
	return

func get_full_conversation() -> Dictionary:
	var c_object = get_conversation()
	match(c_object.type):
		"Conversation":
			var result = {"data": c_object.data}
			if c_object.data.messages != "-1":
				result["message_list_data"] = get_node_by_type_and_id("MessageList", c_object.data.messages).data
				if result.message_list_data.message_list.size() > 0:
					result["message_data"] = []
					result["lines_data"] = []
					for message_id in result.message_list_data.message_list:
						var temp_message = get_node_by_type_and_id("ConversationMessage", message_id)
						result.message_data.append(temp_message.data)
						if temp_message.data.line_id != "-1":
							result.lines_data.append(get_node_by_type_and_id("Lines", temp_message.data.line_id).data)
			return result
	return {}

func get_conversation() -> NodeData:
	var next_node = get_node_by_id(conversation_state.current_conversation)
	match(next_node.type):
		"Conversation":
			conversation_state.current_conversation = next_node.data.next_id
			return next_node
	return