extends Node2D

func _process(_delta):
	if get_viewport().get_camera_2d():
		var mouse_pos = get_global_mouse_position()
		global_position = mouse_pos
		
		# Visual feedback that reticle is working
		modulate = Color(1, 1, 1, 1)  # Ensure fully visible
