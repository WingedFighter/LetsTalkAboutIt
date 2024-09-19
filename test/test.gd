extends Control

var reached_end: bool = false

func _input(event: InputEvent) -> void:
	if $TalkDisplay.can_transition:
		if event.is_action_pressed("ui_accept"):
			$TalkDisplay.interaction(self)
	else:
		if !$TalkDisplay.is_choosing && event.is_action_pressed("ui_accept"):
			$TalkDisplay.interaction($TalkDisplay.current_interactable)
