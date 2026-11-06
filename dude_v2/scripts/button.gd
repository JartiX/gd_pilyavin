extends Area2D

@export var node_path: NodePath
var node: Node
@onready var sprite: Sprite2D = get_node("Sprite2D")
var active: bool = false

func _ready():
	node = get_node(node_path)

func activate():
	if node:
		if node.has_method("turn_on") and not active:
			sprite.texture = load("res://assets/off_button.png")
			sprite.scale.x = 2
			sprite.scale.y = 2
			node.turn_on()
			active = true
		elif node.has_method("turn_off") and active:
			sprite.texture = load("res://assets/on_button.png")
			sprite.scale.x = 1
			sprite.scale.y = 1
			node.turn_off()
			active = false
