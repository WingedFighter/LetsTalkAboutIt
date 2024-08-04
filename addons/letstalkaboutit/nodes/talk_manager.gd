extends Node
class_name TalkManager

@export var graph_data_save_location: String = "res://graph_data.tres"
@export var talk_state_save_location: String = "res://talk_state.tres"

@export var graph_data: GraphData
@export var talk_state: TalkState

func _ready() -> void:
	load_graph_data()
	load_talk_state()

func set_next_talk(id: String) -> void:
	talk_state.current_talk = id

func load_graph_data() -> void:
	if ResourceLoader.exists(graph_data_save_location):
		var g_data = ResourceLoader.load(graph_data_save_location)
		if g_data is GraphData:
			graph_data = g_data

func load_talk_state() -> void:
	if !talk_state:
		if ResourceLoader.exists(talk_state_save_location):
			var c_data = ResourceLoader.load(talk_state_save_location)
			if c_data is TalkState:
				talk_state = c_data
		else:
			talk_state = TalkState.new()

func save_talk_state() -> void:
	if talk_state:
		if ResourceSaver.save(graph_data, talk_state_save_location) == OK:
			print("TalkBasic State Saved")

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

func get_full_talk() -> Dictionary:
	var c_object = get_talk()
	if !c_object:
		return {}
	match(c_object.type):
		"TalkBasic":
			var result = {"data": c_object.data}
			if c_object.data.messages != "-1":
				result["message_list_data"] = get_node_by_type_and_id("TalkMessageList", c_object.data.messages).data
				if result.message_list_data.message_list.size() > 0:
					result["message_data"] = []
					for message_id in result.message_list_data.message_list:
						var temp_message = get_node_by_type_and_id("TalkMessage", message_id)
						result.message_data.append(temp_message.data)
			return result
		"TalkChoice":
			var result = {"data": c_object.data}
			result.lines_list = c_object.data.line_list_resource.lines_list
			return result
		"TalkBranch":
			var result = {"data": c_object.data}
			if c_object.data.has("flag_name") && talk_state.flags.has(c_object.data.flag_name):
				if talk_state.get_flag(c_object.data.flag_name):
					result["next_id"] = c_object.data.true_next_id
				else:
					result["next_id"] = c_object.data.false_next_id
				set_current_talk_id(result["next_id"])
			return result
		"TalkSetFlag":
			var result = {"data": c_object.data}
			if c_object.data.has("flag_name") && c_object.data.has("flag_value"):
				talk_state.set_flag(c_object.data.flag_name, c_object.data.flag_value)
			return result
	return {}

func get_talk() -> NodeData:
	if get_current_talk_id() == "-1":
		print("Waiting on Choice Input")
		return
	var next_node = get_node_by_id(get_current_talk_id())
	match(next_node.type):
		"TalkBasic":
			set_current_talk_id(next_node.data.next_id)
			return next_node
		"TalkChoice":
			set_current_talk_id("-1")
			return next_node
		"TalkBranch":
			return next_node
		"TalkSetFlag":
			set_current_talk_id(next_node.data.next_id)
			return next_node
	return

func set_current_talk_id(convo: String) -> void:
	talk_state.current_talk = convo

func get_current_talk_id() -> String:
	return talk_state.current_talk
