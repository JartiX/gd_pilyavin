extends Node2D

var speed: float = 0
var max_speed: float = 500
var velocity: Vector2 = Vector2(0,0)

@onready var speed_label: Label = get_node("SpeedLabel")
@onready var shield: Sprite2D = get_node("ShipSprite/ShieldSprite")

var shield_restoration: float = 0
var life_time: float = 0
var life_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layer := CanvasLayer.new()
	life_label = Label.new()
	life_label.position = Vector2(10, 10)
	layer.add_child(life_label)
	add_child(layer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		speed += 50 * delta
		if speed > max_speed:
			speed = max_speed
	elif Input.is_action_pressed("ui_down"):
		speed -= 50 * delta
		if speed < 0:
			speed = 0
	
	if Input.is_action_pressed("ui_left"):
		rotation -= 5 * delta
		if speed > max_speed:
			speed = max_speed
	if Input.is_action_pressed("ui_right"):
		rotation += 5 * delta
		
	life_time += delta
	life_label.text = "Life time: %.1f s" % life_time

	var x = 0.1 * cos(rotation+PI/2)
	var y = 0.1 * sin(rotation+PI/2)
	
	velocity = speed * delta * Vector2(x,y).normalized()
	speed_label.text = "%f" % velocity.length()
	speed_label.pivot_offset = speed_label.size / 2
	speed_label.rotation = -rotation
	
	position += velocity
	
	if shield_restoration > 0:
		shield_restoration -= delta
	else:
		shield.visible = true

func damaged():
	life_time = 0
	shield.visible = false
	shield_restoration = 1.0
