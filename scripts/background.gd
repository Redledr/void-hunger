extends CanvasLayer

# ── Config ────────────────────────────────────────────────────────────────────
const STAR_COUNT_GPU := 500
const STAR_COUNT_CPU := 300
const NEBULA_LAYERS  := 4
const DRIFT_SPEED    := 8.0

# ── State ─────────────────────────────────────────────────────────────────────
var _nebula_nodes: Array = []
var _use_gpu:      bool  = false

func _ready() -> void:
	layer  = -10
	_use_gpu = _gpu_supported()
	_build_nebula()
	if _use_gpu:
		_build_stars_gpu()
	else:
		_build_stars_cpu()

# ── GPU check ─────────────────────────────────────────────────────────────────
func _gpu_supported() -> bool:
	var renderer: String = ProjectSettings.get_setting(
		"rendering/renderer/rendering_method", "gl_compatibility"
	)
	return renderer in ["forward_plus", "mobile"]

# ── Nebula ────────────────────────────────────────────────────────────────────
func _build_nebula() -> void:
	var screen := Vector2(1920.0, 1080.0)

	var palettes := [
		Color(0.18, 0.05, 0.38, 0.06),
		Color(0.05, 0.08, 0.35, 0.05),
		Color(0.28, 0.05, 0.18, 0.05),
		Color(0.05, 0.15, 0.28, 0.04),
	]

	for i in range(NEBULA_LAYERS):
		var p           := CPUParticles2D.new()
		p.z_index        = -5
		p.amount         = 6
		p.lifetime       = 18.0
		p.preprocess     = 9.0
		p.one_shot       = false
		p.explosiveness  = 0.0
		p.randomness     = 1.0

		p.emission_shape        = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = screen * 0.6
		p.position = screen * 0.5 + Vector2(
			randf_range(-200.0, 200.0),
			randf_range(-100.0, 100.0)
		)

		p.direction            = Vector2(1.0, 0.2).normalized()
		p.spread               = 180.0
		p.gravity              = Vector2.ZERO
		p.initial_velocity_min = DRIFT_SPEED * 0.4
		p.initial_velocity_max = DRIFT_SPEED * 1.2
		p.scale_amount_min     = 180.0
		p.scale_amount_max     = 380.0
		p.color                = palettes[i % palettes.size()]

		var curve := Gradient.new()
		curve.add_point(0.0, Color(1, 1, 1, 0.0))
		curve.add_point(0.3, Color(1, 1, 1, 1.0))
		curve.add_point(0.7, Color(1, 1, 1, 1.0))
		curve.add_point(1.0, Color(1, 1, 1, 0.0))
		p.color_ramp = curve

		add_child(p)
		_nebula_nodes.append(p)

# ── Stars — GPU path ──────────────────────────────────────────────────────────
func _build_stars_gpu() -> void:
	var screen := Vector2(1920.0, 1080.0)

	# Use float division to avoid INTEGER_DIVISION warning.
	var configs := [
		{ "amount": STAR_COUNT_GPU,             "size_min": 0.5, "size_max": 1.8,
		  "speed_min": 0.0, "speed_max": 0.5,  "alpha": 0.45 },
		{ "amount": int(STAR_COUNT_GPU / 3.0),  "size_min": 1.5, "size_max": 3.5,
		  "speed_min": 0.0, "speed_max": 1.2,  "alpha": 0.75 },
	]

	for cfg in configs:
		var p                  := GPUParticles2D.new()
		p.z_index               = -4
		p.amount                = cfg["amount"]
		p.lifetime              = 60.0
		p.preprocess            = 30.0
		p.one_shot              = false
		p.explosiveness         = 0.0
		p.randomness            = 1.0
		p.fixed_fps             = 0
		p.fract_delta           = true
		p.position              = screen * 0.5

		var pm                  := ParticleProcessMaterial.new()
		pm.emission_shape       = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pm.emission_box_extents = Vector3(screen.x, screen.y, 0.0)
		pm.direction            = Vector3(0.0, 1.0, 0.0)
		pm.spread               = 180.0
		pm.gravity              = Vector3.ZERO
		pm.initial_velocity_min = cfg["speed_min"]
		pm.initial_velocity_max = cfg["speed_max"]
		pm.scale_min            = cfg["size_min"]
		pm.scale_max            = cfg["size_max"]
		pm.color                = Color(1.0, 1.0, 1.0, cfg["alpha"])

		var scale_curve     := CurveXYZTexture.new()
		var c               := Curve.new()
		c.add_point(Vector2(0.0, 0.8))
		c.add_point(Vector2(0.5, 1.0))
		c.add_point(Vector2(1.0, 0.8))
		scale_curve.curve_x  = c
		scale_curve.curve_y  = c
		pm.scale_curve       = scale_curve

		p.process_material = pm
		add_child(p)

# ── Stars — CPU fallback ──────────────────────────────────────────────────────
func _build_stars_cpu() -> void:
	var screen := Vector2(1920.0, 1080.0)

	var configs := [
		{ "amount": STAR_COUNT_CPU,             "size_min": 0.8, "size_max": 2.0,
		  "speed_min": 0.0, "speed_max": 0.5,  "alpha": 0.4 },
		{ "amount": int(STAR_COUNT_CPU / 3.0),  "size_min": 1.5, "size_max": 3.5,
		  "speed_min": 0.0, "speed_max": 1.0,  "alpha": 0.7 },
	]

	for cfg in configs:
		var p                  := CPUParticles2D.new()
		p.z_index               = -4
		p.amount                = cfg["amount"]
		p.lifetime              = 60.0
		p.preprocess            = 30.0
		p.one_shot              = false
		p.explosiveness         = 0.0
		p.randomness            = 1.0

		p.emission_shape        = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = screen * 0.5
		p.position              = screen * 0.5

		p.direction            = Vector2(0.0, 1.0)
		p.spread               = 180.0
		p.gravity              = Vector2.ZERO
		p.initial_velocity_min = cfg["speed_min"]
		p.initial_velocity_max = cfg["speed_max"]
		p.scale_amount_min     = cfg["size_min"]
		p.scale_amount_max     = cfg["size_max"]
		p.color                = Color(1.0, 1.0, 1.0, cfg["alpha"])

		var curve := Gradient.new()
		curve.add_point(0.0, Color(1, 1, 1, 0.0))
		curve.add_point(0.3, Color(1, 1, 1, 1.0))
		curve.add_point(0.7, Color(1, 1, 1, 1.0))
		curve.add_point(1.0, Color(1, 1, 1, 0.0))
		p.color_ramp = curve

		add_child(p)
