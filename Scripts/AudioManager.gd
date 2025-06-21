extends Node

@onready var intro_player: AudioStreamPlayer = $IntroPlayer
@onready var main_player: AudioStreamPlayer = $MainPlayer

func _ready():
	intro_player.process_mode = Node.PROCESS_MODE_ALWAYS
	main_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	main_player.stream.loop = true
	
	intro_player.finished.connect(_on_intro_finished)
	
	intro_player.play()

func _on_intro_finished():
	main_player.play()

func stop_music():
	intro_player.stop()
	main_player.stop()
