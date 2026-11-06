extends CharacterBody2D

@onready var animation = get_node("Sprite2D/AnimationPlayer")
@onready var sprite = get_node("Sprite2D")
@onready var jump_player: AudioStreamPlayer = get_node("JumpPlayer")
@onready var step_player: AudioStreamPlayer = get_node("StepPlayer")

enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, STUN}

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800
const STUN_TIME = 0.5
const PICKUP_DISTANCE = 40
const THROW_FORCE = 400

var bounce_delay = 0
var double_jump = true
var current_state: State = State.IDLE;
var held_box: RigidBody2D = null

var interactive = null

signal bump;
signal hit;

func _ready() -> void:
	set_state(State.IDLE)

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
			if "Box" == result.collider.name:
				held_box = result.collider
				held_box.hold(self)
				break
			if result.collider is Area2D:
				interactive = result.collider
	if event.is_action_released("pickup"):
		if interactive and interactive.has_method("activate"):
			interactive.activate()
			interactive = null
		elif  held_box:
			var direction = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
			direction.y = -0.5
			var impulse = direction * THROW_FORCE
			held_box.release(impulse)
			held_box = null	
		

func set_state(new_state: State):
	current_state = new_state

func handle_idle(delta):
	animation.play("idle")
	
	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		#sprite.flip_h = direction < 0
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 40) # add sliding
		#velocity.x = 0

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump = true
		jump_player.play()
		set_state(State.JUMP)

func handle_run(delta):
	animation.play("run")
	if not step_player.playing:
		step_player.play()
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		step_player.stop()
		set_state(State.IDLE)
		return
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump = true
		step_player.stop()
		jump_player.play()
		set_state(State.JUMP)

func handle_jump(delta):
	animation.play("jump")

	if Input.is_action_just_pressed("jump") and double_jump:
		velocity.y = JUMP_VELOCITY
		double_jump = false
		jump_player.play()
		set_state(State.DOUBLE_JUMP)

	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)

func handle_double_jump(delta):
	animation.play("double_jump")

	if velocity.y > 0:
		set_state(State.JUMP)

	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)

func handle_stun(delta):
	if bounce_delay <= 0:
		set_state(State.IDLE)
	bounce_delay -= delta

func update_flip():
	sprite.flip_h = velocity.x < 0

func handle_collisions(delta):
	var current_platform = null
	
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "Wall" in collider.name:
			var normal = collision.get_normal()
			if abs(normal.x) > 0.8:
				velocity = normal * SPEED
				bounce_delay = STUN_TIME
				set_state(State.STUN)
		if "StaticBox" in collider.name:
			var normal = collision.get_normal()
			if normal.y > 0.8:
				hit.emit()
				velocity = normal * 4 * SPEED
				set_state(State.JUMP)
		if "JumpBox" in collider.name:
			var normal = collision.get_normal()
			if normal.y < -0.8:
				bump.emit()
				velocity.y = normal.y * SPEED * 2
				set_state(State.JUMP)
		if "Bridge" in collider.name:
			current_platform = collider
		if "Rock" in collider.name:
			var normal = collision.get_normal()
			collider.apply_impulse(-normal * 10)
		
	if Input.is_action_just_pressed("down") and current_platform != null:
		var collision = current_platform.get_child(0)
		collision.disabled = true
		await get_tree().create_timer(0.1).timeout
		collision.disabled = false

func handle_held(delta):
	if held_box:
		#var offset_x = 30 if sprite.flip_h else -30
		held_box.global_transform.origin = global_position + Vector2(0, -50)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			handle_run(delta)
		State.JUMP:
			handle_jump(delta)
		State.DOUBLE_JUMP:
			handle_double_jump(delta)
		State.STUN:
			handle_stun(delta)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	handle_collisions(delta)
	update_flip()
	
	move_and_slide()

	handle_held(delta)
	
	if is_on_floor() and current_state in [State.JUMP, State.DOUBLE_JUMP]:
		if abs(velocity.x) > 0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)
