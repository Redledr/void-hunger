extends Node2D

@export var mass_value = 1.0

var color = Color.GRAY
var size = 0.0
var obj_type = ""

var orbit_angle = 0.0
var orbit_radius = 0.0
var orbit_speed = 0.0
var black_hole_pos = Vector2.ZERO
var target_orbit_radius = 0.0

var nudge_velocity = Vector2.ZERO
var is_being_nudged = false
var nudge_decay = 0.92

var trail_points: Array = []
var max_trail_length = 20

@onready var body = $BodyRect  # Change to Polygon2D in scene
@onready var glow = $GlowRect  # Change to Polygon2D in scene
@onready var hitbox = $HitArea/Shape

func create_regular_polygon(sides: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(sides):
		var angle = (2 * PI * i) / sides
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _compare_object_mass(a: String, b: String) -> bool:
	return ObjectData.DATA[a]["mass"] < ObjectData.DATA[b]["mass"]

func setup(start_pos, p_obj_type, bh_pos):
	obj_type = p_obj_type
	black_hole_pos = bh_pos

	var d = ObjectData.get_data(obj_type)
	mass_value = d.get("mass", mass_value)
	color = d.get("color", color)
	size = d.get("size", size)

	mass_value *= GameState.get_mass_multiplier()

	var sorted_types = ObjectData.DATA.keys()
	sorted_types.sort_custom(Callable(self, "_compare_object_mass"))
	var index = sorted_types.find(obj_type)
	var sides = 3 + index
	if sides > 12:
		sides = 12
	
	if index < 5:
		var circle = CircleShape2D.new()
		circle.radius = size / 2.0
		hitbox.shape = circle
	else:
		var poly = ConvexPolygonShape2D.new()
		poly.points = create_regular_polygon(sides, size / 2.0)
		hitbox.shape = poly

	position = start_pos

	orbit_radius = start_pos.distance_to(black_hole_pos)
	target_orbit_radius = randf_range(150.0, 400.0)

	orbit_angle = (start_pos - black_hole_pos).angle()
	orbit_speed = randf_range(0.3, 0.7) * (1.0 if randf() < 0.5 else -1.0)

	var visual_sides = sides if sides > 3 else 16  # Use 16 sides for circle visuals
	var body_points = create_regular_polygon(visual_sides, size / 2.0)
	var glow_points = create_regular_polygon(visual_sides, size * 1.25)
	
	if body is Polygon2D:
		body.polygon = body_points
		body.color = color * 1.6
	elif body is ColorRect:
		body.size = Vector2(size, size)
		body.position = -body.size / 2
		body.color = color * 1.6
	
	if glow is Polygon2D:
		glow.polygon = glow_points
		glow.color = Color(color.r, color.g, color.b, 0.12)
	elif glow is ColorRect:
		glow.size = Vector2(size * 2.5, size * 2.5)
		glow.position = -glow.size / 2
		glow.color = Color(color.r, color.g, color.b, 0.12)

func apply_nudge(nudge_dir: Vector2, strength: float = 80.0):
	orbit_radius -= strength
	nudge_velocity += nudge_dir * strength * 0.5
	is_being_nudged = true

func _process(delta):
	orbit_angle += orbit_speed * delta

	orbit_radius -= (orbit_radius - target_orbit_radius) * delta * 2.5

	if is_being_nudged:
		nudge_velocity *= nudge_decay
		orbit_radius += nudge_velocity.length() * delta * -0.1
		target_orbit_radius = min(target_orbit_radius, orbit_radius)
		if nudge_velocity.length() < 1.0:
			is_being_nudged = false
			nudge_velocity = Vector2.ZERO

	orbit_radius = max(orbit_radius, 0.0)

	var orbit_pos = black_hole_pos + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	position = orbit_pos

	trail_points.push_front(position)
	if trail_points.size() > max_trail_length:
		trail_points.pop_back()

	queue_redraw()

func _absorb():
	GameState.add_mass(mass_value)
	## TODO: trigger particle burst here
	queue_free()

func _draw():
	for i in range(trail_points.size() - 1):
		var a = float(trail_points.size() - i) / trail_points.size()
		var c = color
		c.a = a * 0.5
		draw_line(to_local(trail_points[i]), to_local(trail_points[i + 1]), c, 2.0)

func _on_hit_area_area_entered(_area: Area2D) -> void:
	_absorb()
