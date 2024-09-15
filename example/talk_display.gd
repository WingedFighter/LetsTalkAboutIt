extends Control

@export_range(0.01, 0.1) var text_speed: float = .05
@export_range(0.01, 0.1) var skip_buffer: float = .05

@onready var talk_container: PanelContainer = $ScreenMargins/GridContainer/TalkContainer
@onready var name_container: PanelContainer = $NameContainer
@onready var screen_margins: MarginContainer = $ScreenMargins
@onready var text_animation_player: AnimationPlayer = $TextAnimation

var can_transition: bool = true
var current_text: String
var current_interactable: Node

var current_talk_type: String
var current_talk_messages: Array
var current_message_index: int

var test_animation_started: bool = false

# Still todo:
#  Add handle other talk nodes
#  Add portrait loading
#  Add characters

func _ready() -> void:
    visible = false

func _input(event: InputEvent) -> void:
    if can_transition:
        if event.is_action_pressed("ui_accept"):
            print("HEre")
            interaction($Control)
    else:
        if event.is_action_pressed("ui_accept"):
            interaction(current_interactable)

func _process(delta: float) -> void:
    set_name_container_position()

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

func setup_text_animation(talk_text: Array) -> void:
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
    if !visible:
        visible = true
    
    text_animation_player.play("text/play_text")

func destroy_text_animation() -> void:
    if text_animation_player.has_animation_library("text"):
        text_animation_player.stop()
        text_animation_player.remove_animation_library("text")
    
    if visible:
        visible = false

func is_text_animation_finished() -> bool:
    if visible:
        return text_animation_player.current_animation_position >= \
            text_animation_player.current_animation_length
    return true

func skip_text_animation() -> void:
    if visible and text_animation_player.active:
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
    setup_text_animation(current_message.lines)
    start_text_animation()

func display_talk_choice(talk: Dictionary) -> void:
    pass

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
            display_talk_choice(talk)
        "TalkBasic":
            display_talk_basic(talk)

func get_character_from_id(_character_id: String) -> Dictionary:
    return {"character_name": "Test Name 1"}