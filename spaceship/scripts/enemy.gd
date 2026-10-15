extends Node2D

signal colided

var orbit_radius: float = 60

var acceleration: Vector2 = Vector2(0,0)
var velocity: Vector2 = Vector2(0,0)
var max_force: float = 100
var max_speed: float = 100

var min_distance: float = 100
var max_distance: float = 1000

@onready var window = get_parent().get_window()
@onready var size = $EnemyBoid.texture.get_size()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = randi_range(0 + size.x, window.size.x - size.x)
	position.y = randi_range(0 + size.y, window.size.y - size.y)
	
	velocity = Vector2(randf_range(0,1), randf_range(0,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	position += velocity * delta
	acceleration *= 0
	rotation = velocity.angle()
	
func apply_force(force: Vector2):
	acceleration = force

func seek(target: Vector2):
	var direction = target - position
	var desired_velocity = direction.normalized() * max_speed
	#if direction.length() > max_distance:
		#return

	var a = remap(direction.length(), min_distance, max_distance, 0, 1)
	var steering = desired_velocity - velocity * a
	steering.limit_length(max_force)
	apply_force(steering)
	
	
func flee(target: Vector2):
	var direction = position - target
	var desired_velocity = direction.normalized() * max_speed
	if direction.length() > max_distance/4:
		return
	var steering = desired_velocity - velocity
	steering.limit_length(max_force)
	apply_force(steering)
	

func pursue(target: Vector2, target_velocity: Vector2):
	var direction = target - position
	var speed: float = velocity.length()
	if speed == 0:
		speed = max_speed
	var ahead_time: float = direction.length() / speed
	var predict = target + target_velocity * ahead_time
	seek(predict)


func evade(target: Vector2, target_velocity: Vector2):
	var direction = target - position
	var speed: float = velocity.length()
	if direction.length()  > max_distance:
		return
	if speed == 0:
		speed = max_speed
	var ahead_time: float = direction.length() / speed
	var predict = target + target_velocity * ahead_time
	flee(predict)


func borders():
	var steering := Vector2.ZERO
	var margin := 60.0

	if position.x < margin:
		steering.x += max_speed

	if position.x > window.size.x - margin:
		steering.x -= max_speed

	if position.y < margin:
		steering.y += max_speed

	if position.y > window.size.y - margin:
		steering.y -= max_speed

	if steering.length() > 0:
		steering = steering.normalized() * max_speed
		steering -= velocity
		steering = steering.limit_length(max_force)
		apply_force(steering)
		
		
func separate(group: Node2D):
	var steering: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			var away: Vector2 = -direction.normalized()
			away *= 1 / distance
			steering += away
			count += 1
	if count > 0:
		steering /= count
		steering = steering.normalized() * max_speed
		steering -= velocity
		steering = steering.limit_length(max_force)
		apply_force(steering)
	

func cohesion(group: Node2D):
	var center_mass: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			center_mass += child.position
			count += 1
	if count > 0:
		center_mass /= count
		seek(center_mass)
	
	
func alignment(group: Node2D):
	var mean_velocity: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child:
			continue
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			mean_velocity += child.velocity
			count += 1
	if count > 0:
		mean_velocity /= count
		mean_velocity = mean_velocity.normalized() * max_speed
		mean_velocity -= velocity
		var steering = mean_velocity - velocity
		apply_force(steering.limit_length(max_force))


func orbit(target: Vector2, radius: float):
	var to_target: Vector2 = target - position
	var distance: float = to_target.length()
	if distance == 0:
		return
	var inward: Vector2 = to_target / distance
	var tangent: Vector2 = inward.orthogonal()

	var radial_error: float = clampf((distance - radius) / radius, -1.0, 1.0)
	var desired_velocity: Vector2 = (tangent + inward * radial_error * 2.0).normalized() * max_speed
	var steering: Vector2 = (desired_velocity - velocity).limit_length(max_force)
	apply_force(steering)


func _on_enemy_area_area_entered(area: Area2D) -> void:
	if area.name == "ShipArea":
		colided.emit()
