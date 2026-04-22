# floating_text.gd
# Spawned on absorption — floats upward and fades out.
extends Node2D

var _lifetime:  float = 0.8
var _elapsed:   float = 0.0
var _velocity:  Vector2 = Vector2(0, -120)
var _label:     Label

func _ready() -> void:
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 18)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)

func setup(pos: Vector2, text: String, color: Color, size: float = 18) -> void:
	position = pos
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_font_size_override("font_size", int(size))
	# offset label so it centers on spawn position
	_label.position = Vector2(-40, -10)

func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = _elapsed / _lifetime
	position  += _velocity * delta
	modulate   = Color(1, 1, 1, 1.0 - t)
	if _elapsed >= _lifetime:
		queue_free()
