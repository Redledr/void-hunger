extends Node2D

var black_hole
var spawn_timer
var screen_size

var object_types = ["asteroid", "planet", "star", "neutron_star"]

func _ready():
	screen_size = get_viewport().get_visible_rect().size

	black_hole = Node2D.new()
	black_hole.set_script(load("res://scripts/black_hole.gd"))
	black_hole.position = screen_size / 2.0
	add_child(black_hole)

	var ui = CanvasLayer.new()
	ui.set_script(load("res://scripts/ui.gd"))
	add_child(ui)

	spawn_timer = Timer.new()
	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.connect("timeout", _spawn_object)
	add_child(spawn_timer)
	spawn_timer.start()

	GameState.mass_changed.connect(_update_spawn_timer)
	
	var env = WorldEnvironment.new()
	var environment = Environment.new()

	environment.glow_enabled = true
	environment.glow_intensity = 0.8
	environment.glow_strength = 1.2
	environment.glow_bloom = 0.2
	environment.glow_hdr_threshold = 0.6

	env.environment = environment
	add_child(env)

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

func _get_object_type():
	if GameState.pull_level >= 10:
		return object_types[randi() % 4]
	elif GameState.pull_level >= 6:
		return object_types[randi() % 3]
	elif GameState.pull_level >= 3:
		return object_types[randi() % 2]
	else:
		return "asteroid"

func _spawn_object():
	var obj = Node2D.new()
	obj.set_script(load("res://scripts/space_object.gd"))
	add_child(obj)
	obj.setup(_get_random_edge_position(), _get_object_type(), screen_size / 2.0)

func _update_spawn_timer():
	spawn_timer.wait_time = GameState.get_spawn_interval()
