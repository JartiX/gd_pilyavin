extends Node2D

@export var max_health: int = 3
@export var health_texture: Texture2D

var current_health = max_health:
	set(value):
		current_health = clampi(value, 0, max_health)
		if is_node_ready():
			_update_health()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _update_health():
	var container: HBoxContainer = $Panel/HBoxContainer
	if container:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
		
		for i in max_health:
			var health = TextureRect.new()
			health.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			health.custom_minimum_size = Vector2(64, 64)
			health.texture = health_texture
			health.modulate = Color.GOLD if i < current_health else Color(0.35, 0.35, 0.35, 0.5)
			health.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			container.add_child(health)
		
