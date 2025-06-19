extends Control

@export var game_scene: PackedScene
@export var options_scene: PackedScene

@onready var play_button    = $CenterContainer/VBoxContainer/PlayButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_packed(game_scene)

func _on_options_pressed():
	get_tree().change_scene_to_packed(options_scene)
