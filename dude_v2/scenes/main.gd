extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {
	"Training": preload("res://scenes/levels/training_level.tscn")
}

var player: CharacterBody2D = null
@onready var player_scene = preload("res://scenes/characters/physics_dude.tscn")

@onready var world = $World

@onready var menu = $UI/Menu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = player_scene.instantiate()
	add_child(player)
	load_level("Training")
	
	
func load_level(name):
	if current_level:
		current_level.queue_free()
	current_level = levels[name].instantiate()
	player.global_position = current_level.get_node("Spawn").global_position
	world.add_child(current_level)
		
func pause():
	if not get_tree().paused:
		menu.visible = true
	else:
		menu.visible = false
	get_tree().paused = not get_tree().paused

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		pause()
