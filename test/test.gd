extends Node2D

var reached_end: bool = false

func _process(_delta: float) -> void:
	while(!reached_end):
		var talk = $TalkManager.get_full_talk()
		print(talk)
		if !talk:
			get_tree().quit()
		if talk.data.has("end") && talk.data.end:
			reached_end = true
		if talk.data.has("next_id_list"):
			$TalkManager.set_current_talk_id(talk.data.next_id_list[talk.data.next_id_list.keys()[0]])
