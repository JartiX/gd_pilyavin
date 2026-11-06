extends RigidBody2D

@onready var collision = $CollisionShape2D
var holder: Node2D = null

const HOLD_OFFSET: Vector2 = Vector2(0, -50)


func hold(character: Node2D) -> void:
	holder = character
	collision.set_deferred("disabled", true)
	freeze = true


func release(throw_force: Vector2 = Vector2.ZERO) -> void:
	holder = null
	collision.set_deferred("disabled", false)
	freeze = false
	if throw_force != Vector2.ZERO:
		apply_central_impulse(throw_force)


func _physics_process(_delta: float) -> void:
	if holder:
		global_position = holder.global_position + HOLD_OFFSET
