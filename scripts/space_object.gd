extends Node2D

@export var mass_value = 1.0

var target_pos = Vector2.ZERO
var color = Color.GRAY
var size = 10.0

var rect
var velocity = Vector2.ZERO
var spiral_strength = 260.0
var gravity_strength = 140.0

var trail_points: Array = []
var max_trail_length = 20

const OBJECT_DATA = {
	# --- Subatomic -----
	"quark": { "mass": 0.1, "color": Color(0.55, 0.55, 0.95), "size": 4 },
	"electron": { "mass": 0.12, "color": Color(0.60, 0.60, 1.00), "size": 4 },
	"proton": { "mass": 0.15, "color": Color(0.70, 0.65, 1.00), "size": 5 },
	"neutron": { "mass": 0.18, "color": Color(0.75, 0.70, 1.00), "size": 5 },

	# --- Atomic / molecular -----
	"dust": { "mass": 0.3, "color": Color(0.65, 0.62, 0.55), "size": 5 },
	"atom": { "mass": 0.5, "color": Color(0.50, 0.80, 1.00), "size": 6 },
	"molecule": { "mass": 0.9, "color": Color(0.40, 0.75, 0.95), "size": 7 },
	"cells": { "mass": 1.2, "color": Color(0.30, 0.70, 0.85), "size": 8 },
	"bacterium": { "mass": 1.5, "color": Color(0.30, 0.65, 0.75), "size": 8 },
	"virus": { "mass": 2.0, "color": Color(0.35, 0.60, 0.80), "size": 9 },

	# --- Geological -----
	"sand": { "mass": 3.0, "color": Color(0.76, 0.70, 0.55), "size": 5 },
	"pebbles": { "mass": 6.0, "color": Color(0.62, 0.58, 0.50), "size": 7 },
	"rocks": { "mass": 12.0, "color": Color(0.48, 0.48, 0.52), "size": 9 },
	"boulders": { "mass": 25.0, "color": Color(0.38, 0.38, 0.42), "size": 11 },
	"mountains": { "mass": 60.0, "color": Color(0.30, 0.30, 0.35), "size": 14 },

	# --- Planetary -----
	"asteroid": { "mass": 120.0, "color": Color(0.65, 0.52, 0.42), "size": 12 },
	"planet": { "mass": 500.0, "color": Color(0.25, 0.55, 0.95), "size": 18 },

	# --- Stellar -----
	"drawfstar": { "mass": 2500.0, "color": Color(1.0, 0.95, 0.6), "size": 22 },
	"star": { "mass": 5000.0, "color": Color(1.0, 0.85, 0.3), "size": 24 },
	"redgiant": { "mass": 12000.0, "color": Color(1.0, 0.45, 0.15), "size": 28 },
	"neutron_star": { "mass": 30000.0, "color": Color(0.9, 0.3, 1.0), "size": 22 },

	# --- Galactic -----
	"starcluster": { "mass": 80000.0, "color": Color(1.0, 0.9, 0.5), "size": 30 },
	"nebula": { "mass": 150000.0, "color": Color(0.7, 0.4, 1.0), "size": 34 },
	"galaxy": { "mass": 800000.0, "color": Color(0.55, 0.25, 1.0), "size": 40 },
	"galaxycluster": { "mass": 5000000.0, "color": Color(1.0, 0.45, 0.75), "size": 46 },
	"supercluster": { "mass": 20000000.0, "color": Color(0.85, 0.6, 1.0), "size": 52 },

	# --- Endgame -----
	"observableuniversefragment": { "mass": 100000000.0, "color": Color(0.85, 0.85, 1.0), "size": 60 },
	"observableuniverse": { "mass": 500000000.0, "color": Color(1.0, 1.0, 1.0), "size": 68 },
	"multiverse": { "mass": 5000000000.0, "color": Color(1.0, 0.98, 0.9), "size": 80 }
}

func setup(start_pos, obj_type, target):
	position = start_pos
	target_pos = target

	var d = OBJECT_DATA.get(obj_type)
	if d:
		mass_value = d.mass
		color = d.color
		size = d.size

	mass_value *= GameState.get_mass_multiplier()

	var dir = (target_pos - position).normalized()
	var tangent = Vector2(-dir.y, dir.x)
	velocity = tangent * randf_range(80.0, 140.0)
	if randf() < 0.5:
		velocity = -velocity

	gravity_strength *= sqrt(size)
	spiral_strength /= sqrt(size)

	# outer glow layer
	var glow = ColorRect.new()
	glow.size = Vector2(size * 2.5, size * 2.5)
	glow.position = -glow.size / 2
	glow.color = Color(color.r, color.g, color.b, 0.12)
	add_child(glow)

	# inner body
	rect = ColorRect.new()
	rect.size = Vector2(size, size)
	rect.position = -rect.size / 2
	rect.color = color * 1.6
	add_child(rect)

func _process(delta):
	var to_center = target_pos - position
	var dist = to_center.length()

	if dist > 0:
		var dir = to_center / dist
		var tangent = Vector2(-dir.y, dir.x)

		var orbit = clamp(dist / 300.0, 0.5, 2.5)
		var pull = clamp(200.0 / (dist + 50.0), 0.3, 3.0)

		velocity += (tangent * spiral_strength * orbit + dir * gravity_strength * pull) * delta

	spiral_strength *= 0.999
	position += velocity * delta
	velocity *= 0.992

	trail_points.push_front(position)
	if trail_points.size() > max_trail_length:
		trail_points.pop_back()

	queue_redraw()

	if dist < 15.0:
		GameState.add_mass(mass_value)
		queue_free()

func _draw():
	for i in range(trail_points.size() - 1):
		var a = float(trail_points.size() - i) / trail_points.size()
		var c = color
		c.a = a * 0.6
		draw_line(to_local(trail_points[i]), to_local(trail_points[i + 1]), c, 2.0)
