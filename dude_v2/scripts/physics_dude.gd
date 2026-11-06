extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800
var bounce_delay = 0.4
var double_jump = true

@onready var animation = get_node("Sprite2D/AnimationPlayer")
@onready var sprite = get_node("Sprite2D")

signal bump;
signal hit;

func _physics_process(delta: float) -> void:
	if bounce_delay > 0:
		bounce_delay -= delta
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if bounce_delay < 0:
		velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		double_jump = true
	
	if Input.is_action_just_pressed("ui_up") and not is_on_floor() and double_jump:
		velocity.y = JUMP_VELOCITY
		double_jump = false
		animation.play("double_jump")
	print(velocity)
	if not is_on_floor() and double_jump == false and velocity.y > 0:
		animation.play("jump")
	
	elif not is_on_floor() and double_jump == true:
		animation.play("jump")
	elif direction != 0 and is_on_floor():
		sprite.flip_h = direction < 0
		animation.play("run")
	elif direction == 0 and is_on_floor():
		animation.play("idle")
	
	move_and_slide()
	
	var current_platform = null
	
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "Wall" in collider.name:
			var normal = collision.get_normal()
			if abs(normal.x) > 0.8:
				velocity += normal * SPEED
				bounce_delay = 1.0
		if "StaticBox" in collider.name:
			var normal = collision.get_normal()
			if normal.y > 0.8:
				hit.emit()
				velocity += normal * 1.1 * SPEED
		if "JumpBox" in collider.name:
			var normal = collision.get_normal()
			if normal.y < -0.8:
				bump.emit()
				velocity.y += normal.y * SPEED
		if "Bridge" in collider.name:
			current_platform = collider
		if "Rock" in collider.name:
			var normal = collision.get_normal()
			collider.apply_impulse(-normal * 100)
		
	if Input.is_action_just_pressed("ui_down") and current_platform != null:
		var collision = current_platform.get_child(0)
		collision.disabled = true
		await get_tree().create_timer(0.1).timeout
		collision.disabled = false
