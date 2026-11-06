extends StaticBody2D

@export var burn_duration: float = 3.0
var active := false
var hit_bodies: Dictionary = {}


func _ready() -> void:
	$FlamePlayer.stream.loop = true
	$Trigger.body_entered.connect(_on_trigger)
	$FlameArea.body_entered.connect(_hit)
	$BurnTimer.timeout.connect(turn_off)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func _on_trigger(body: Node2D) -> void:
	if body.has_method("knockback") or body.has_method("hold"):
		if not active:
			turn_on()
		_hit(body)


func turn_on() -> void:
	if active:
		return
	active = true
	hit_bodies.clear()
	$AnimatedSprite2D.play("hit")
	$Sparks.emitting = true
	$FlamePlayer.play()
	$BurnTimer.start(burn_duration)
	for body in $FlameArea.get_overlapping_bodies():
		_hit(body)


func turn_off() -> void:
	active = false
	$BurnTimer.stop()
	$AnimatedSprite2D.play("off")
	$Sparks.emitting = false
	$FlamePlayer.stop()


func _hit(body: Node2D) -> void:
	if not active or hit_bodies.has(body.get_instance_id()):
		return
	if not (body.has_method("knockback") or body.has_method("hold")):
		return
	hit_bodies[body.get_instance_id()] = true
	$HitPlayer.play()
	if body.has_method("knockback"):
		var side = -1.0 if body.global_position.x < global_position.x else 1.0
		body.knockback(Vector2(side * 300.0, -420.0))


func _on_animation_finished() -> void:
	if active and $AnimatedSprite2D.animation == "hit":
		$AnimatedSprite2D.play("on")
