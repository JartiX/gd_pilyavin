extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var particles = $Area2D/GPUParticles2D
@onready var fan_player = $FanPlayer

const WIND_FORCE: float = 1500.0


func _ready() -> void:
	fan_player.stream.loop = true
	turn_off()


func turn_on() -> void:
	print("FAN ON")
	sprite.play("on")
	fan_player.play()
	area.set_deferred("monitoring", true)
	particles.one_shot = false
	particles.emitting = true
	particles.restart()
	print("emitting=", particles.emitting)


func turn_off() -> void:
	print("FAN OFF")
	sprite.play("off")
	fan_player.stop()
	area.set_deferred("monitoring", false)
	particles.emitting = false


func _physics_process(delta: float) -> void:
	if not area.monitoring:
		return
	var dir = Vector2.UP.rotated(global_rotation)
	for body in area.get_overlapping_bodies():
		if body is CharacterBody2D:
			body.velocity += dir * WIND_FORCE * delta
		elif body is RigidBody2D:
			body.apply_central_force(dir * WIND_FORCE)
