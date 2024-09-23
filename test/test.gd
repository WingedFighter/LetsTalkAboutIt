extends Control

var reached_end: bool = false

func _input(event: InputEvent) -> void:
	if $CanvasLayer/TalkDisplay.can_transition:
		if event.is_action_pressed("ui_accept"):
			$CanvasLayer/TalkDisplay.interaction(self)
	else:
		if !$CanvasLayer/TalkDisplay.is_choosing && event.is_action_pressed("ui_accept"):
			$CanvasLayer/TalkDisplay.interaction($CanvasLayer/TalkDisplay.current_interactable)
