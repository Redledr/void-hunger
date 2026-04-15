# black_hole.gd
# Attach to the ROOT node of res://scenes/black_hole.tscn
#
# Scene structure expected:
#   Node2D  (this script)
#   ├─ Body     : ColorRect      — visual
#   └─ PullZone : Area2D         — detects space objects entering
#       └─ Shape: CollisionShape2D (CircleShape2D, updated as mass grows)
#
# Collision layers (set in Project Settings > Physics > 2D):
#   Layer 1 — black hole  (PullZone lives here)
#   Layer 2 — space objects (their HitArea lives here, mask includes layer 1)
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
	var circle   := CircleShape2D.new()
	circle.radius = current_size / 4.0
	pull_shape.shape = circle

func _on_mass_changed() -> void:
	call_deferred("_update_size")
