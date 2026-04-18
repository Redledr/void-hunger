extends Node2D

@export var mass_value: float = 1.0

var color: Color = Color.GRAY
var size:  float = 0.0
var obj_type: String = ""

var orbit_angle:         float   = 0.0
var orbit_radius:        float   = 0.0
var orbit_speed:         float   = 0.0
var black_hole_pos:      Vector2 = Vector2.ZERO
var target_orbit_radius: float   = 0.0

# ── Nudge / spiral ──────────────────────────────────────────────────────────
const BASE_LERP_SPEED:  float = 2.5
const NUDGE_LERP_BOOST: float = 5.0

var _nudge_lerp_speed: float = BASE_LERP_SPEED
var _spiraling:        bool  = false

# ── Trail (circular buffer) ─────────────────────────────────────────────────
# Length is read from GameState so the skill tree can extend it.
var _max_trail:  int = 20
var _trail:      PackedVector2Array = PackedVector2Array()
var _trail_head: int = 0
var _trail_count:int = 0

@onready var body:   Polygon2D        = $Body
@onready var glow:   Polygon2D        = $Glow
@onready var hitbox: CollisionShape2D = $HitArea/Shape

# ── Setup ───────────────────────────────────────────────────────────────────

func setup(start_pos: Vector2, p_obj_type: String, bh_pos: Vector2) -> void:
	obj_type       = p_obj_type
	black_hole_pos = bh_pos

	var d := ObjectData.get_data(obj_type)
	mass_value = d.get("mass", mass_value) * GameState.get_mass_multiplier()
	color      = d.get("color", color)
	size       = d.get("size",  size)

	var index: int = ObjectData.get_sorted_index(obj_type)
	var sides: int = clampi(3 + index, 3, 12)

	if index < 5:
		var circle    := CircleShape2D.new()
		circle.radius  = size / 2.0
		hitbox.shape   = circle
	else:
		var poly    := ConvexPolygonShape2D.new()
		poly.points  = _make_polygon(sides, size / 2.0)
		hitbox.shape = poly

	position            = start_pos
	orbit_radius        = start_pos.distance_to(black_hole_pos)
	target_orbit_radius = randf_range(150.0, 400.0)
	orbit_angle         = (start_pos - black_hole_pos).angle()
	orbit_speed         = randf_range(0.3, 0.7) * (1.0 if randf() < 0.5 else -1.0)

	var visual_sides := 16 if sides <= 3 else sides
	body.polygon = _make_polygon(visual_sides, size / 2.0)
	body.color   = color * 1.6
	glow.polygon = _make_polygon(visual_sides, size * 1.25)
	glow.color   = Color(color.r, color.g, color.b, 0.12)

	# Trail length driven by skill tree.
	_max_trail = int(GameState.get_skill_value("trail_length", 20.0))
	_trail.resize(_max_trail)

# ── Nudge ───────────────────────────────────────────────────────────────────

func apply_nudge(_strength: float = 0.0) -> void:
	if _spiraling:
		return
	# Check nudge resistance — reduced by skill tree.
	var data     := ObjectData.get_data(obj_type)
	var base_resist: float = data.get("nudge_resist", 0.0)
	var reduction:   float = GameState.get_skill_value("nudge_resist_reduction", 0.0)
	var final_resist := maxf(0.0, base_resist - reduction)
	if randf() < final_resist:
		return  # Resisted — TODO: flash object to give visual feedback

	_spiraling        = true
	_nudge_lerp_speed = BASE_LERP_SPEED + NUDGE_LERP_BOOST

# ── Per-frame ───────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	orbit_angle += orbit_speed * delta

	if _spiraling:
		var rate := GameState.get_skill_value("spiral_rate", 60.0)
		target_orbit_radius = maxf(0.0, target_orbit_radius - rate * delta)

	orbit_radius      -= (orbit_radius - target_orbit_radius) * delta * _nudge_lerp_speed
	_nudge_lerp_speed  = lerpf(_nudge_lerp_speed, BASE_LERP_SPEED, delta * 4.0)
	orbit_radius       = maxf(orbit_radius, 0.0)
	position           = black_hole_pos + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius

	_trail_push(position)
	queue_redraw()

# ── Draw ────────────────────────────────────────────────────────────────────

func _draw() -> void:
	if _trail_count < 2:
		return
	for i in range(_trail_count - 1):
		# Walk backwards from current position toward the tail
		var idx_a := (_trail_head + _trail_count - 1 - i)     % _max_trail
		var idx_b := (_trail_head + _trail_count - 2 - i)     % _max_trail
		var alpha := 1.0 - float(i) / float(_trail_count)
		draw_line(to_local(_trail[idx_a]), to_local(_trail[idx_b]),
				  Color(color.r, color.g, color.b, alpha * 0.5), 2.0)

# ── Absorption ──────────────────────────────────────────────────────────────

func _absorb() -> void:
	GameState.add_mass(mass_value)
	GameState.add_energy(mass_value * 0.1)
	if GameState.particles != null:
		GameState.particles.burst(position, color, size)
	queue_free()

func _on_hit_area_area_entered(_area: Area2D) -> void:
	_absorb()

# ── Helpers ─────────────────────────────────────────────────────────────────

static func _make_polygon(sides: int, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.resize(sides)
	for i in range(sides):
		var angle := (TAU * i) / sides
		pts[i] = Vector2(cos(angle), sin(angle)) * radius
	return pts

func _trail_push(pt: Vector2) -> void:
	if _trail_count < _max_trail:
		_trail[(_trail_head + _trail_count) % _max_trail] = pt
		_trail_count += 1
	else:
		_trail[_trail_head] = pt
		_trail_head = (_trail_head + 1) % _max_trail
