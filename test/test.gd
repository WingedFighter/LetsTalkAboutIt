extends Node2D

var reached_end: bool = false

func _process(_delta: float) -> void:
	while(!reached_end):
		var conversation = $ConversationManager.get_full_conversation()
		print(conversation)
		if conversation.data.end:
			reached_end = true
