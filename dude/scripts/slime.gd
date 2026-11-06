extends StaticBody2D

@export var bounce_speed: float = 620.0


func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func bounce(body: CharacterBody2D) -> void:
	body.velocity.y = -bounce_speed
	$AnimatedSprite2D.play("hit")
	$Particles.restart()
	$AnimatedSprite2D.scale = Vector2(1.2, 0.55)
	$AnimatedSprite2D.position.y = 6.75
	var tween = create_tween().set_parallel()
	tween.tween_property($AnimatedSprite2D, "scale", Vector2.ONE, 0.25)
	tween.tween_property($AnimatedSprite2D, "position:y", 0.0, 0.25)


func _on_animation_finished() -> void:
	$AnimatedSprite2D.play("default")
