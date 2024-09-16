extends Node
class_name TalkCharacter

@export var character_id: String = "default"
@export var character_name: String = "Default"
@export var character_base_panel: String 

enum MOOD {
    SAD,
    HAPPY,
    ANGRY,
    SURPRISED,
    NEUTRAL
}

func _ready() -> void:
    add_to_group("TalkCharacter")