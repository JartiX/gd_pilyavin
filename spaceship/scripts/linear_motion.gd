extends Node2D

var velocity: Vector2 = Vector2(0, 0)
var angular_speed: float = 0.1
@onready var window = get_parent().get_window()
@onready var size = get_node("Asteroid").texture.get_size()

signal colided

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(randi_range(-100,100), randi_range(-100, 100))
	angular_speed = randf_range(0.1, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	rotation += angular_speed * delta
	
	if position.x > window.size.x - size.x / 2:
		velocity.x *= -1
	if position.x < size.x / 2:
		velocity.x *= -1
	if position.y < size.y / 2:
		velocity.y *= -1
	if position.y > window.size.y - size.y / 2:
		velocity.y *= -1
	


func _on_asteroid_area_area_entered(area: Area2D) -> void:
	colided.emit()
