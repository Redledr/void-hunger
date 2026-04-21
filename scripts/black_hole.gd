extends Node2D

@onready var pull_shape: CollisionShape2D = $PullZone/Shape

var _circle_shape := CircleShape2D.new()
var _rotation_t: float = 0.0

func _ready() -> void:
	pull_shape.shape = _circle_shape
	_update_size()
	GameState.mass_changed.connect(_on_mass_changed)

func _process(delta: float) -> void:
	_rotation_t += GameConfig.rotation_speed * delta
	queue_redraw()

func _update_size() -> void:
	var s := GameConfig.black_hole_base_size + log(maxf(1.0, GameState.mass)) * GameConfig.black_hole_mass_scale
	_circle_shape.radius = s
	queue_redraw()

func _on_mass_changed() -> void:
	call_deferred("_update_size")

func _draw() -> void:
	var r := GameConfig.black_hole_base_size + log(maxf(1.0, GameState.mass)) * GameConfig.black_hole_mass_scale
	_draw_glow(r)
	_draw_accretion_disk(r)
	_draw_core(r)
	_draw_event_horizon(r)

func _draw_glow(r: float) -> void:
	for i in range(GameConfig.glow_layers, 0, -1):
		var t := float(i) / float(GameConfig.glow_layers)
		var glow_r := r * (1.0 + t * GameConfig.glow_radius_mult)
		var alpha := GameConfig.glow_alpha_peak * (1.0 - t)
		var col := Color(
			lerpf(0.35, 0.05, t),
			lerpf(0.05, 0.02, t),
			lerpf(0.55, 0.08, t),
			alpha
		)
		draw_circle(Vector2.ZERO, glow_r, col)

func _draw_accretion_disk(r: float) -> void:
	var inner := r * GameConfig.disk_inner_scale
	var outer := r * GameConfig.disk_outer_scale

	for band in range(GameConfig.disk_bands):
		var t_band := float(band) / float(GameConfig.disk_bands)
		var band_r := lerpf(inner, outer, t_band)
		var heat := 1.0 - t_band
		var col := Color(
			lerpf(0.6, 1.0, heat),
			lerpf(0.1, 0.55, heat),
			lerpf(0.3, 0.05, heat),
			lerpf(0.04, 0.28, heat)
		)

		var back_pts := PackedVector2Array()
		for i in range(GameConfig.arc_segments + 1):
			var angle := (float(i) / float(GameConfig.arc_segments)) * TAU + _rotation_t
			var x := cos(angle) * band_r
			var y := sin(angle) * band_r * GameConfig.disk_tilt
			if y >= 0.0:
				back_pts.append(Vector2(x, y))
		if back_pts.size() >= 2:
			for i in range(back_pts.size() - 1):
				draw_line(back_pts[i], back_pts[i + 1], col, GameConfig.disk_line_width)

func _draw_core(r: float) -> void:
	draw_circle(Vector2.ZERO, r * 1.08, Color(0.28, 0.0, 0.42, 0.85))
	draw_circle(Vector2.ZERO, r, Color(0.0, 0.0, 0.0, 1.0))

func _draw_event_horizon(r: float) -> void:
	var inner := r * GameConfig.disk_inner_scale
	var outer := r * GameConfig.disk_outer_scale

	for band in range(GameConfig.disk_bands):
		var t_band := float(band) / float(GameConfig.disk_bands)
		var band_r := lerpf(inner, outer, t_band)
		var heat := 1.0 - t_band
		var col := Color(
			lerpf(0.6, 1.0, heat),
			lerpf(0.1, 0.55, heat),
			lerpf(0.3, 0.05, heat),
			lerpf(0.04, 0.28, heat)
		)

		var front_pts := PackedVector2Array()
		for i in range(GameConfig.arc_segments + 1):
			var angle := (float(i) / float(GameConfig.arc_segments)) * TAU + _rotation_t
			var x := cos(angle) * band_r
			var y := sin(angle) * band_r * GameConfig.disk_tilt
			if y < 0.0:
				front_pts.append(Vector2(x, y))
		if front_pts.size() >= 2:
			for i in range(front_pts.size() - 1):
				draw_line(front_pts[i], front_pts[i + 1], col, GameConfig.disk_line_width)

	draw_arc(Vector2.ZERO, r, 0.0, TAU, GameConfig.arc_segments, Color(0.75, 0.35, 1.0, 0.45), 1.2)