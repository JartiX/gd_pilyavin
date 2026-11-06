extends Node2D

@export var node_path: NodePath
var node: Node
var active: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

const ON_TEXTURE_PATH = "res://assets/on_button.png"
const OFF_TEXTURE_PATH = "res://assets/off_button.png"


func _ready() -> void:
	node = get_node_or_null(node_path)
	print("Button target: ", node)
	area.body_entered.connect(_on_body_entered)


func activate() -> void:
	if node:
		if node.has_method("turn_on") and not active:
			sprite.texture = load(ON_TEXTURE_PATH)
			node.turn_on()
			active = true
		elif node.has_method("turn_off") and active:
			sprite.texture = load(OFF_TEXTURE_PATH)
			node.turn_off()
			active = false


func _on_body_entered(body: Node2D) -> void:
	print("Button touched by: ", body.name)
	if body is CharacterBody2D:
		activate()
