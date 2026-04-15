# main.gd
# Root scene controller.  Owns the spawn timer and coordinates the
# black hole and UI sub-scenes.
#
# Scene structure expected:
#   Node2D  (this script)           — Main
#   ├─ BlackHole  (instance of res://scenes/black_hole.tscn)
#   ├─ UI         (instance of res://scenes/ui.tscn  — CanvasLayer)
#   └─ SpawnTimer : Timer
extends Node2D

# Preload once at parse time — not on every spawn call.
const SpaceObjectScene := preload("res://scenes/space_object.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size

	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.timeout.connect(_spawn_object)
	spawn_timer.start()

	GameState.mass_changed.connect(_on_mass_changed)

	_setup_environment()

func _setup_environment() -> void:
	var env         := WorldEnvironment.new()
	var environment := Environment.new()

	environment.glow_enabled       = true
	environment.glow_intensity     = 0.8
	environment.glow_strength      = 1.2
	environment.glow_bloom         = 0.2
	environment.glow_hdr_threshold = 0.6

	env.environment = environment
	add_child(env)

# ── Spawning ───────────────────────────────────────────────────────

func _get_random_edge_position() -> Vector2:
	match randi() % 4:
		0: return Vector2(randf() * screen_size.x, 0)
		1: return Vector2(randf() * screen_size.x, screen_size.y)
		2: return Vector2(0,              randf() * screen_size.y)
		_: return Vector2(screen_size.x,  randf() * screen_size.y)

func _spawn_object() -> void:
	var types      := GameState.get_unlocked_types()
	var obj_type: String = types[randi() % types.size()]
	var start_pos  := _get_random_edge_position()

	var obj: Node2D = SpaceObjectScene.instantiate()
	add_child(obj)
	# setup() is called after add_child so @onready vars are resolved.
	obj.setup(start_pos, obj_type, screen_size / 2.0)

# ── Callbacks ──────────────────────────────────────────────────────

func _on_mass_changed() -> void:
	spawn_timer.wait_time = GameState.get_spawn_interval()
