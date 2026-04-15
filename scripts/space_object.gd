# space_object.gd
# Attach to the ROOT node of res://scenes/space_object.tscn
#
# Scene structure expected:
#   Node2D  (this script)
#   ├─ GlowRect   : ColorRect   — outer glow visual
#   ├─ BodyRect   : ColorRect   — inner body visual
#   └─ HitArea    : Area2D      — collision with the black hole
#       └─ Shape  : CollisionShape2D (CircleShape2D, radius set in setup)
#
# The Area2D approach removes the per-frame distance check that was
# running on every object every tick.  Instead, the physics engine
# tells us exactly when we've entered the black hole's Area2D.
extends Node2D

# ── Node references (set via @onready once scene tree exists) ──────
@onready var glow_rect:  ColorRect         = $GlowRect
@onready var body_rect:  ColorRect         = $BodyRect
@onready var hit_area:   Area2D            = $HitArea
@onready var hit_shape:  CollisionShape2D  = $HitArea/Shape

# ── State ──────────────────────────────────────────────────────────
var mass_value:       float    = 1.0
var obj_color:        Color    = Color.GRAY
var obj_size:         float    = 10.0

var target_pos:       Vector2  = Vector2.ZERO
var velocity:         Vector2  = Vector2.ZERO
var spiral_strength:  float    = 260.0
var gravity_strength: float    = 140.0

var trail_points:     Array    = []
const MAX_TRAIL:      int      = 20

# ── Setup (called by main.gd after instantiation) ──────────────────
func setup(start_pos: Vector2, obj_type: String, target: Vector2) -> void:
	position   = start_pos
	target_pos = target

	# Read data from the ObjectData autoload — no local copy needed.
	var d: Dictionary = ObjectData.get_data(obj_type)
	if not d.is_empty():
		mass_value = d["mass"]
		obj_color  = d["color"]
		obj_size   = d["size"]

	mass_value *= GameState.get_mass_multiplier()

	# Tangential launch so objects orbit before spiralling in.
	var dir     := (target_pos - position).normalized()
	var tangent := Vector2(-dir.y, dir.x)
	velocity = tangent * randf_range(80.0, 140.0)
	if randf() < 0.5:
		velocity = -velocity

	# Larger objects pull harder but spiral slower — sqrt keeps it
	# feeling consistent across the wide mass range.
	gravity_strength *= sqrt(obj_size)
	spiral_strength  /= sqrt(obj_size)

	_apply_visuals()

# ── Visuals ────────────────────────────────────────────────────────
func _apply_visuals() -> void:
	# Glow layer
	var glow_size := Vector2(obj_size * 2.5, obj_size * 2.5)
	glow_rect.size     = glow_size
	glow_rect.position = -glow_size / 2.0
	glow_rect.color    = Color(obj_color.r, obj_color.g, obj_color.b, 0.12)

	# Body
	var body_size := Vector2(obj_size, obj_size)
	body_rect.size     = body_size
	body_rect.position = -body_size / 2.0
	body_rect.color    = obj_color * 1.6

	# Collision circle — matches the visual body radius.
	var circle        := CircleShape2D.new()
	circle.radius      = obj_size / 2.0
	hit_shape.shape    = circle

# ── Physics ────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	var to_center := target_pos - position
	var dist      := to_center.length()

	if dist > 0.0:
		var dir     := to_center / dist
		var tangent := Vector2(-dir.y, dir.x)
		var orbit   := clampf(dist / 300.0,          0.5, 2.5)
		var pull    := clampf(200.0 / (dist + 50.0), 0.3, 3.0)
		velocity += (tangent * spiral_strength * orbit + dir * gravity_strength * pull) * delta

	spiral_strength *= 0.999
	velocity        *= 0.992
	position        += velocity * delta

	# Store trail in local space so _draw() doesn't need to_local() every frame.
	trail_points.push_front(Vector2.ZERO)   # local origin = current position
	# Shift older points by the movement delta so they stay world-accurate.
	var move := velocity * delta
	for i in range(1, trail_points.size()):
		trail_points[i] -= move
	if trail_points.size() > MAX_TRAIL:
		trail_points.pop_back()

	queue_redraw()

# ── Collision (replaces manual distance check) ─────────────────────
# Connect HitArea.body_entered or area_entered in the editor, OR
# connect it here at runtime.  The black hole should have its own
# Area2D on collision layer 1; space objects on layer 2.
func _on_hit_area_area_entered(_area: Area2D) -> void:
	GameState.add_mass(mass_value)
	queue_free()

# ── Drawing ────────────────────────────────────────────────────────
func _draw() -> void:
	for i in range(trail_points.size() - 1):
		var alpha := float(trail_points.size() - i) / trail_points.size()
		var c     := obj_color
		c.a        = alpha * 0.6
		draw_line(trail_points[i], trail_points[i + 1], c, 2.0)
