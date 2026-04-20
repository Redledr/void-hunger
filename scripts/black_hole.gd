extends Node2D

# ── Constants ────────────────────────────────────────────────────────────────
const BASE_SIZE:        float = 40.0   # core radius at mass 0
const GLOW_LAYERS:      int   = 6      # number of concentric glow rings
const ROTATION_SPEED:   float = 0.18  # radians/sec for the accretion sweep

# Accretion disk: a thin ellipse that rotates, giving life to the hole.
# It's drawn as a series of arcs at slightly offset angles.
const DISK_INNER_SCALE: float = 1.3   # relative to core radius
const DISK_OUTER_SCALE: float = 2.2
const DISK_TILT:        float = 0.35  # vertical squish (0=flat, 1=circle)

@onready var pull_shape: CollisionShape2D = $PullZone/Shape

var _circle_shape  := CircleShape2D.new()
var _rotation_t: float = 0.0   # drives the disk sweep angle

func _ready() -> void:
	pull_shape.shape = _circle_shape
	_update_size()
	GameState.mass_changed.connect(_on_mass_changed)

func _process(delta: float) -> void:
	_rotation_t += ROTATION_SPEED * delta
	queue_redraw()

func _update_size() -> void:
	var s := BASE_SIZE + log(maxf(1.0, GameState.mass)) * 4.0
	_circle_shape.radius = s
	queue_redraw()

func _on_mass_changed() -> void:
	call_deferred("_update_size")

# ── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var r := BASE_SIZE + log(maxf(1.0, GameState.mass)) * 4.0

	_draw_glow(r)
	_draw_accretion_disk(r)
	_draw_core(r)
	_draw_event_horizon(r)

func _draw_glow(r: float) -> void:
	# Soft outer glow — multiple transparent circles stepping outward.
	for i in range(GLOW_LAYERS, 0, -1):
		var t      := float(i) / float(GLOW_LAYERS)
		var glow_r := r * (1.0 + t * 2.8)
		var alpha  := 0.06 * (1.0 - t)
		# Warm purple tint on the inner rings, fading to deep blue-black.
		var col := Color(
			lerpf(0.35, 0.05, t),
			lerpf(0.05, 0.02, t),
			lerpf(0.55, 0.08, t),
			alpha
		)
		draw_circle(Vector2.ZERO, glow_r, col)

func _draw_accretion_disk(r: float) -> void:
	# Draw a tilted elliptical disk as stacked arcs.
	# Split into "front" (below hole) and "back" (above hole) halves
	# so the core occludes correctly.
	var inner := r * DISK_INNER_SCALE
	var outer := r * DISK_OUTER_SCALE
	var tilt   := DISK_TILT

	# Back half (drawn first, behind core).
	_draw_disk_half(inner, outer, tilt, true)

func _draw_disk_front(r: float) -> void:
	var inner := r * DISK_INNER_SCALE
	var outer := r * DISK_OUTER_SCALE
	_draw_disk_half(inner, outer, DISK_TILT, false)

func _draw_disk_half(inner: float, outer: float, tilt: float, back: bool) -> void:
	var steps   := 48
	var y_sign  := -1.0 if back else 1.0
	var sweep   := _rotation_t

	for band in range(4):
		var t_band  := float(band) / 4.0
		var band_r  := lerpf(inner, outer, t_band + 0.08)
		# Hot white-orange near inner edge, fading to dim magenta at outer.
		var heat    := 1.0 - t_band
		var col := Color(
			lerpf(0.6, 1.0, heat),
			lerpf(0.1, 0.55, heat),
			lerpf(0.3, 0.05, heat),
			lerpf(0.06, 0.22, heat)
		)

		var pts := PackedVector2Array()
		for i in range(steps + 1):
			var angle := (float(i) / float(steps)) * PI  # half circle
			var base_a := angle + sweep
			var x := cos(base_a) * band_r
			# Flatten the y axis to create the tilted-disk illusion,
			# and only emit the half we want (front or back).
			var y := sin(base_a) * band_r * tilt * y_sign
			if (back and y <= 0.0) or (not back and y >= 0.0):
				pts.append(Vector2(x, y))

		if pts.size() >= 2:
			for i in range(pts.size() - 1):
				draw_line(pts[i], pts[i + 1], col, 1.5)

func _draw_core(r: float) -> void:
	# The event horizon itself — absolute black with a faint purple rim.
	# Draw from outside in so the darkest circle wins.
	var rim_col := Color(0.28, 0.0, 0.42, 0.85)
	draw_circle(Vector2.ZERO, r * 1.08, rim_col)
	draw_circle(Vector2.ZERO, r,        Color(0.0, 0.0, 0.0, 1.0))

func _draw_event_horizon(r: float) -> void:
	# Front half of the accretion disk — drawn on top of the core.
	_draw_disk_front(r)

	# Thin bright ring at the event horizon edge.
	var ring_col := Color(0.75, 0.35, 1.0, 0.45)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, ring_col, 1.2)