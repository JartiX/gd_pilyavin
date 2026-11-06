extends RigidBody2D

@onready var collision = get_node("CollisionShape2D")

var is_held = false
var holder: Node2D = null

func _physics_process(delta: float) -> void:
	pass

#func _ready() -> void:
	#freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func hold(character: Node2D):
	is_held = true
	holder = character
	freeze = true
	collision.disabled = true
	

func release(throw_force: Vector2 = Vector2.ZERO):
	is_held = false
	holder = null
	freeze = false
	collision.disabled = false
	if throw_force != Vector2.ZERO:
		apply_central_impulse(throw_force)
