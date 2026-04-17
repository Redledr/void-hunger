extends Node2D

const BUILD = "nudge"

const SPACE_OBJECT_SCENE = preload("res://scenes/space_object.tscn")

@onready var black_hole = $BlackHole
@onready var spawn_timer = $SpawnTimer

var screen_size
var max_objects = 40
var active_objects: Array = []

const NUDGE_RADIUS = 80.0
const NUDGE_STRENGTH = 120.0

var mouse_pos = Vector2.ZERO

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.connect("timeout", _spawn_object)
	spawn_timer.start()
	GameState.mass_changed.connect(_update_spawn_timer)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		queue_redraw()

	if BUILD == "nudge":
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_try_nudge(event.position)

func _draw():
	draw_arc(mouse_pos, NUDGE_RADIUS, 0, TAU, 64, Color(1.0, 1.0, 1.0, 0.2), 1.0)

func _try_nudge(click_pos: Vector2):
	for obj in active_objects:
		if not is_instance_valid(obj):
			continue
		var dist = obj.position.distance_to(click_pos)
		if dist <= NUDGE_RADIUS:
			var dir = (black_hole.position - obj.position).normalized()
			obj.apply_nudge(dir, NUDGE_STRENGTH)

func _get_random_edge_position():
	var side = randi() % 4
	if side == 0:
		return Vector2(randf() * screen_size.x, 0)
	elif side == 1:
		return Vector2(randf() * screen_size.x, screen_size.y)
	elif side == 2:
		return Vector2(0, randf() * screen_size.y)
	else:
		return Vector2(screen_size.x, randf() * screen_size.y)

func _spawn_object():
	active_objects = active_objects.filter(func(o): return is_instance_valid(o))
	if active_objects.size() >= max_objects:
		return
	var unlocked = GameState.get_unlocked_types()
	var obj = SPACE_OBJECT_SCENE.instantiate()
	add_child(obj)
	obj.setup(_get_random_edge_position(), unlocked[randi() % unlocked.size()], black_hole.position)
	active_objects.append(obj)

func _update_spawn_timer():
	spawn_timer.wait_time = GameState.get_spawn_interval()
