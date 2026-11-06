extends Node2D

@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	audio_player.stream = load("res://audio/background.ogg")
	#audio_player.volume_db = -10
	#audio_player.volume_db = linear_to_db(0.5)
	audio_player.play()
