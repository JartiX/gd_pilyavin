extends StaticBody2D

@onready var animation = get_node("AnimationPlayer")
@onready var area = get_node("Area2D/CollisionShape2D")
@onready var particles = get_node("GPUParticles2D")
@onready var fan_player: AudioStreamPlayer2D = get_node("FanPlayer")

func _ready() -> void:
	pass

func turn_on():
	animation.play("on")
	fan_player.play()
	area.disabled = false
	particles.emitting = true

func turn_off():
	animation.play("off")
	fan_player.stop()
	area.disabled = true
	particles.emitting = false
