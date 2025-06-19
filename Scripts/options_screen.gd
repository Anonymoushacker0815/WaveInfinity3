extends Control


@export var min_screen_size := Vector2i(600, 600)
@export var max_screen_size := Vector2i(3000, 2000)

@onready var back_button    = $CenterContainer/VBoxContainer/BackButton
@onready var width_edit     = $CenterContainer/VBoxContainer/WidthLineEdit
@onready var height_edit    = $CenterContainer/VBoxContainer/HeightLineEdit
@onready var apply_button   = $CenterContainer/VBoxContainer/ApplyButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	apply_button.pressed.connect(_on_apply_pressed)

	process_mode = Node.PROCESS_MODE_ALWAYS
	for btn in [back_button, apply_button]:
		btn.process_mode = Node.PROCESS_MODE_ALWAYS

	var ws = DisplayServer.window_get_size()
	width_edit.text  = str(ws.x)
	height_edit.text = str(ws.y)


func _on_back_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/home_screen.tscn")

func _on_apply_pressed():
	var w = int(width_edit.text)
	var h = int(height_edit.text)
	var clamped_w = clamp(w, min_screen_size.x, max_screen_size.x)
	var clamped_h = clamp(h, min_screen_size.y, max_screen_size.y)
	
	if w != clamped_w or h != clamped_h:
		push_warning("Screen size must be between %d×%d and %d×%d. Clamped to %d×%d."
			% [min_screen_size.x, min_screen_size.y,
			max_screen_size.x, max_screen_size.y,
			clamped_w, clamped_h])
	DisplayServer.window_set_size(Vector2i(clamped_w, clamped_h))
	width_edit.text  = str(clamped_w)
	height_edit.text = str(clamped_h)
