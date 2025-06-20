extends Node

@onready var intro_player: AudioStreamPlayer = $IntroPlayer
@onready var main_player: AudioStreamPlayer = $MainPlayer

func _ready():
	# Set both players to ignore pauses
	intro_player.process_mode = Node.PROCESS_MODE_ALWAYS
	main_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set main soundtrack to loop
	main_player.stream.loop = true
	
	# Connect signals
	intro_player.finished.connect(_on_intro_finished)
	
	# Play intro
	intro_player.play()

func _on_intro_finished():
	main_player.play()

func stop_music():
	intro_player.stop()
	main_player.stop()
