extends Node2D

var base_size = 40.0
var rect

func _ready():
	rect = ColorRect.new()
	rect.color = Color(0.05, 0.0, 0.1)
	_update_size()
	add_child(rect)
	GameState.mass_changed.connect(_on_mass_changed)

func _update_size():
	var current_size = base_size + log(max(1.0, GameState.mass)) * 4.0
	rect.size = Vector2(current_size, current_size)
	rect.position = Vector2(-current_size / 2.0, -current_size / 2.0)

func _on_mass_changed():
	_update_size()
