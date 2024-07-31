extends Node2D

var reached_end: bool = false

func _process(_delta: float) -> void:
	while(!reached_end):
		var conversation = $ConversationManager.get_full_conversation()
		print(conversation)
		if !conversation:
			get_tree().quit()
		if conversation.data.has("end") && conversation.data.end:
			reached_end = true
		if conversation.has("next_id_list"):
			$ConversationManager.set_current_conversation_id(conversation.next_id_list[conversation.next_id_list.keys()[0]])
