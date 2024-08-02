extends Node
class_name ConversationManager

@export var graph_data_save_location: String = "res://graph_data.tres"
@export var conversation_state_save_location: String = "res://conversation_state.tres"

@export var graph_data: GraphData
@export var conversation_state: ConversationState

func _ready() -> void:
	load_graph_data()
	load_conversation_state()

func set_next_conversation(id: String) -> void:
	conversation_state.current_conversation = id

func load_graph_data() -> void:
	if ResourceLoader.exists(graph_data_save_location):
		var g_data = ResourceLoader.load(graph_data_save_location)
		if g_data is GraphData:
			graph_data = g_data

func load_conversation_state() -> void:
	if !conversation_state:
		if ResourceLoader.exists(conversation_state_save_location):
			var c_data = ResourceLoader.load(conversation_state_save_location)
			if c_data is ConversationState:
				conversation_state = c_data
		else:
			conversation_state = ConversationState.new()

func save_conversation_state() -> void:
	if conversation_state:
		if ResourceSaver.save(graph_data, conversation_state_save_location) == OK:
			print("Conversation State Saved")

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
	if !c_object:
		return {}
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
		"ConversationChoice":
			var result = {"data": c_object.data}
			if c_object.data.choice_list.size() > 0:
				result["choice_list_data"] = []
				for choice_id in result.data.choice_list:
					result.choice_list_data.append(get_node_by_type_and_id("Lines", choice_id).data)
			if c_object.data.next_id_list.size() > 0:
				result["next_id_list"] = {}
				for n_id in c_object.data.next_id_list:
					result.next_id_list[n_id] = c_object.data.next_id_list[n_id]
			return result
		"ConversationBranch":
			var result = {"data": c_object.data}
			if c_object.data.has("flag_name") && conversation_state.flags.has(c_object.data.flag_name):
				if conversation_state.get_flag(c_object.data.flag_name):
					result["next_id"] = c_object.data.true_next_id
				else:
					result["next_id"] = c_object.data.false_next_id
				set_current_conversation_id(result["next_id"])
			return result
		"TalkSetFlag":
			var result = {"data": c_object.data}
			if c_object.data.has("flag_name") && c_object.data.has("flag_value"):
				conversation_state.set_flag(c_object.data.flag_name, c_object.data.flag_value)
			return result
	return {}

func get_conversation() -> NodeData:
	if get_current_conversation_id() == "-1":
		print("Waiting on Choice Input")
		return
	var next_node = get_node_by_id(get_current_conversation_id())
	match(next_node.type):
		"Conversation":
			set_current_conversation_id(next_node.data.next_id)
			return next_node
		"ConversationChoice":
			set_current_conversation_id("-1")
			return next_node
		"ConversationBranch":
			return next_node
		"TalkSetFlag":
			set_current_conversation_id(next_node.data.next_id)
			return next_node
	return

func set_current_conversation_id(convo: String) -> void:
	conversation_state.current_conversation = convo

func get_current_conversation_id() -> String:
	return conversation_state.current_conversation