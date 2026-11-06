extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $DudeSprite
@onready var step_sound: AudioStreamPlayer2D = $StepSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var landing_sound: AudioStreamPlayer2D = $LandingSound

const SPEED: int = 200
const JUMP_SPEED: float = -400.0
const GRAVITY = 800
const BOUNCE_DELAY: float = 0.3
const PICKUP_DISTANCE: float = 40.0
const THROW_FORCE: float = 300.0

var state = "idle"
var bounce_delay: float = 0.0
var held_box: RigidBody2D = null
var step_delay: float = 0.0
var hit_time: float = 0.0


func _ready() -> void:
	$AudioListener2D.make_current()
	animation.play(state)


func _physics_process(delta: float) -> void:
	hit_time = maxf(0.0, hit_time - delta)
	var was_on_floor = is_on_floor()
	var previous_position = position
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction = Input.get_axis("left", "right")

	if bounce_delay > 0:
		bounce_delay -= delta
	else:
		velocity.x = direction * SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED
		jump_sound.play()

	if hit_time > 0:
		state = "hit"
	elif not is_on_floor():
		state = "double jump"
	elif direction != 0:
		sprite.flip_h = direction < 0
		state = "walk"
	else:
		state = "idle"
	animation.play(state)

	var falling_speed = velocity.y
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		landing_sound.play()
		step_delay = 0.28
	if is_on_floor() and abs(position.x - previous_position.x) > 0.1:
		step_delay -= delta
		if step_delay <= 0:
			step_sound.play()
			step_delay = 0.28
	else:
		step_delay = 0.0
		step_sound.stop()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider == null:
			continue
		var normal = collision.get_normal()
		if collider.has_method("bounce") and normal.y < -0.8 and falling_speed > 0:
			collider.bounce(self)
			jump_sound.play()

		if "StaticBox".to_lower() in collider.name.to_lower():
			print("Bump box")
			if normal.y > 0.8:
				velocity += normal * SPEED * 1.1
		if "Wall".to_lower() in collider.name.to_lower():
			print("Bump wall")
			if abs(normal.x) > 0.8:
				velocity += normal * SPEED
				bounce_delay = BOUNCE_DELAY
		if "JumpBox".to_lower() in collider.name.to_lower():
			if normal.y < -0.8:
				velocity.y = normal.y * SPEED * 3
		if "Rock".to_lower() in collider.name.to_lower():
			collider.apply_impulse(-normal * 10)

	if held_box:
		held_box.global_transform.origin = global_position + Vector2(0, -50)


func knockback(impulse: Vector2) -> void:
	velocity = impulse
	bounce_delay = BOUNCE_DELAY
	hit_time = 0.35
	state = "hit"
	animation.play(state)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and not held_box:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius = PICKUP_DISTANCE
		query.shape = shape
		query.transform = Transform2D(0, global_position)
		query.collide_with_areas = true
		query.exclude = [self]
		var results = space_state.intersect_shape(query)
		for result in results:
			if "Box".to_lower() in result.collider.name.to_lower():
				held_box = result.collider
				held_box.hold(self)
				break

	if event.is_action_released("pickup"):
		if held_box:
			var direction = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
			direction.y = -0.5
			var impulse = direction * THROW_FORCE
			held_box.release(impulse)
			held_box = null
