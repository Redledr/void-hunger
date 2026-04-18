extends Node2D

const BASE_SIZE: float = 40.0

@onready var body:       ColorRect         = $Body
@onready var pull_shape: CollisionShape2D  = $PullZone/Shape

# Reuse one shape instance — mutate its size instead of allocating each update.
var _rect_shape := RectangleShape2D.new()

func _ready() -> void:
	pull_shape.shape = _rect_shape
	body.color       = Color(0.05, 0.0, 0.1)
	_update_size()
	GameState.mass_changed.connect(_on_mass_changed)

func _update_size() -> void:
	var s := BASE_SIZE + log(maxf(1.0, GameState.mass)) * 4.0

	body.size       = Vector2(s, s)
	body.position   = Vector2(-s * 0.5, -s * 0.5)
	_rect_shape.size = Vector2(s, s)

func _on_mass_changed() -> void:
	call_deferred("_update_size")
