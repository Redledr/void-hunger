extends Node2D

const BASE_SIZE: float = 40.0

@onready var body:       ColorRect         = $Body
@onready var pull_zone:  Area2D            = $PullZone
@onready var pull_shape: CollisionShape2D  = $PullZone/Shape

func _ready() -> void:
	body.color = Color(0.05, 0.0, 0.1)
	_update_size()
	GameState.mass_changed.connect(_on_mass_changed)

func _update_size() -> void:
	# Grows logarithmically so it never gets absurdly large.
	var current_size: float = BASE_SIZE + log(maxf(1.0, GameState.mass)) * 4.0

	body.size     = Vector2(current_size, current_size)
	body.position = Vector2(-current_size / 2.0, -current_size / 2.0)

	# Keep the collision zone in sync with the visual.
	var rect := RectangleShape2D.new()
	rect.size = Vector2(current_size, current_size)
	pull_shape.shape = rect

func _on_mass_changed() -> void:
	call_deferred("_update_size")
