extends Resource
class_name ConversationState

@export var current_conversation: String

func _init(p_current_conversation: String = "0") -> void:
    current_conversation = p_current_conversation

func save_data(location: String) -> bool:
    if ResourceSaver.save(self, location) == OK:
        return true
    else:
        print ("Error saving data")
        return false