extends Control

@export_range(0.01, 0.1) var text_speed: float = .05
@export_range(0.01, 0.1) var skip_buffer: float = .05
@export var default_theme: Theme = preload("res://talk_display/default_ui.tres")

@onready var talk_container: PanelContainer = $ScreenMargins/GridContainer/TalkContainer
@onready var name_container: PanelContainer = $NameContainer
@onready var screen_margins: MarginContainer = $ScreenMargins
@onready var text_animation_player: AnimationPlayer = $TextAnimation

var can_transition: bool = true
var is_choosing: bool = false
var current_text: String
var current_interactable: Node

var current_talk_type: String
var current_talk_messages: Array
var current_message_index: int

var test_animation_started: bool = false

func _ready() -> void:
	hide_basic_talk()

func _input(event: InputEvent) -> void:
	if can_transition:
		if event.is_action_pressed("ui_accept"):
			interaction($Control)
	else:
		if !is_choosing && event.is_action_pressed("ui_accept"):
			interaction(current_interactable)

func _process(_delta: float) -> void:
	set_name_container_position()

func show_basic_talk() -> void:
	screen_margins.visible = true
	name_container.visible = true

func hide_basic_talk() -> void:
	screen_margins.visible = false
	name_container.visible = false

func get_basic_talk_visibility() -> bool:
	return screen_margins.visible && name_container.visible

func set_name_container_position() -> void:
	var desired_position: Vector2 = talk_container.position
	desired_position.x += int(screen_margins.get_theme_constant("margin_left") * 3.0 / 2.0)

	if desired_position != name_container.position:
		name_container.position = desired_position

func can_interact(i_node: Node) -> bool:
	for node in i_node.get_children():
		if node is TalkManager:
			return true
		if i_node.get_child_count() > 0:
			if can_interact(node):
				return true
	return false

func get_talk_manager(i_node: Node) -> TalkManager:
	for node in i_node.get_children():
		if node is TalkManager:
			return node
		if i_node.get_child_count() > 0:
			var result = get_talk_manager(node)
			if result:
				return result
	return null

func set_name_label(name_text: String) -> void:
	name_container.get_node("VBoxContainer/NameLabel").text = name_text

func set_talk_texture(icon_path: String) -> void:
	if icon_path && len(icon_path) > 0:
		talk_container.get_node("TalkMargins/TalkInteriorContainer/TalkTexture").texture = load(icon_path)

func set_text_animation(talk_text: Array) -> void:
	destroy_text_animation()
	
	if len(talk_text) <= 0:
		return
	
	var first = true
	for line in talk_text:
		if first:
			current_text = line
			first = false
		else:
			current_text = current_text + "\n" + line
	
	var talk_label = talk_container.get_node("TalkMargins/TalkInteriorContainer/TalkLabel")
	talk_label.text = current_text

	var text_animation_length: float = current_text.length() * text_speed
	# Need to test and see if this needs to be 100 instead of 10
	var text_frame_count: int = int(text_animation_length * 10)

	var text_animation := Animation.new()
	text_animation.length = text_animation_length + .1
	text_animation.loop_mode = Animation.LOOP_NONE

	var talk_label_path: NodePath = talk_label.get_path()
	var track_id: int = text_animation.add_track(Animation.TYPE_VALUE)
	text_animation.track_set_path(track_id, "%s:visible_ratio" % talk_label_path)

	for frame in text_frame_count:
		var time: float = frame / float(text_frame_count) * text_animation_length
		var ratio: float = time / text_animation_length
		text_animation.track_insert_key(track_id, time, ratio)
	text_animation.track_insert_key(track_id, text_animation_length + .1, 1.0)

	var text_animation_library := AnimationLibrary.new()
	text_animation_library.add_animation("play_text", text_animation)

	text_animation_player.add_animation_library("text", text_animation_library)

func start_text_animation() -> void:
	if not get_basic_talk_visibility():
		show_basic_talk()
	
	text_animation_player.play("text/play_text")

func destroy_text_animation() -> void:
	if text_animation_player.has_animation_library("text"):
		text_animation_player.stop()
		text_animation_player.remove_animation_library("text")
	
	if get_basic_talk_visibility():
		hide_basic_talk()

func is_text_animation_finished() -> bool:
	if get_basic_talk_visibility():
		return text_animation_player.current_animation_position >= \
			text_animation_player.current_animation_length
	return true

func skip_text_animation() -> void:
	if get_basic_talk_visibility() and text_animation_player.active:
		if text_animation_player.current_animation_position / \
		  text_animation_player.current_animation_length > skip_buffer:
			text_animation_player.seek(text_animation_player.current_animation_length)

func interaction(i_node: Node) -> void:
	if !i_node:
		return
	if can_interact(i_node):
		current_interactable = i_node
		if can_transition:
			var talk_manager = get_talk_manager(i_node)
			handle_talk(talk_manager)
		elif is_text_animation_finished():
			if current_message_index >= len(current_talk_messages) - 1:
				var talk_manager = get_talk_manager(i_node)
				handle_talk(talk_manager)
			else:
				display_message()
		else:
			skip_text_animation()

func display_talk_basic(talk: Dictionary) -> void:
	current_talk_type = "TalkBasic"
	current_talk_messages = talk.message_data
	current_message_index = -1
	display_message()

func display_message() -> void:
	current_message_index += 1
	if len(current_talk_messages) <= current_message_index:
		destroy_text_animation()
		return
	var current_message = current_talk_messages[current_message_index]
	var character = get_character_from_id(current_message.character_id)

	set_name_label(character.character_name)
	set_talk_texture(character.character_base_panel)
	set_text_animation(current_message.lines)
	start_text_animation()

func display_talk_choice(talk: Dictionary, talk_manager: TalkManager) -> void:
	is_choosing = true
	if get_basic_talk_visibility():
		hide_basic_talk()
	for choice in talk.data.line_list:
		add_choice(talk.data.line_list[choice], talk.data.next_id_list[choice], talk_manager)

func talk_end() -> void:
	get_tree().quit()

func handle_talk(talk_manager: TalkManager) -> void:
	var talk: Dictionary = talk_manager.get_full_talk()
	# Display talk
	if !talk:
		if !can_transition:
			talk_end()
	can_transition = false
	match(talk.type):
		"TalkStart":
			handle_talk(talk_manager)
		"TalkEnd":
			talk_end()
		"TalkChoice":
			display_talk_choice(talk, talk_manager)
		"TalkBasic":
			display_talk_basic(talk)

func get_character_from_id(character_id: String) -> TalkCharacter:
	var character_nodes = get_tree().get_nodes_in_group("TalkCharacter")
	for node in character_nodes:
		if node.character_id == character_id:
			return node
	return TalkCharacter.new()

func add_choice(choice_text: String, next_id: String, talk_manager: TalkManager) -> Button:
	var button_to_add = Button.new()
	$Choices.add_child(button_to_add)
	button_to_add.add_to_group("TalkChoiceButtons")
	button_to_add.set_theme(default_theme)
	button_to_add.add_theme_font_size_override("font_size", 48)
	button_to_add.set_text(choice_text)
	button_to_add.pressed.connect(handle_choice.bind(next_id, talk_manager))
	return button_to_add

func remove_choices() -> void:
	is_choosing = false
	var choice_list = get_tree().get_nodes_in_group("TalkChoiceButtons")
	for choice in choice_list:
		choice.queue_free()

func handle_choice(next_id: String, talk_manager: TalkManager) -> void:
	talk_manager.set_current_talk_id(next_id)
	remove_choices()
	call_deferred("handle_talk", talk_manager)
