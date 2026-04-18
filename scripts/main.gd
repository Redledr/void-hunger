# main.gd
# Root script for the main scene (Node2D).
#
# Responsibilities:
#   - Spawn and track space objects
#   - Handle nudge input (gated behind mechanic_nudge skill)
#   - Draw nudge radius indicator
#   - Expose ParticleManager to the rest of the scene via a static reference
extends Node2D

const SPACE_OBJECT_SCENE := preload("res://scenes/space_object.tscn")

# Static reference so space_object.gd can call GameState.particles.burst()
# without needing a node path.

@onready var black_hole:        Node2D = $BlackHole
@onready var spawn_timer:       Timer  = $SpawnTimer
@onready var debug_label:       Label  = $DebugLabel
@onready var particle_manager:  Node2D = $ParticleManager

const MAX_OBJECTS:    int   = 40
const NUDGE_RADIUS:   float = 80.0
const NUDGE_STRENGTH: float = 120.0

var screen_size:    Vector2 = Vector2.ZERO
var active_objects: Array   = []
var mouse_pos:      Vector2 = Vector2.ZERO

# Whether the nudge ring should be visible at all.
var _nudge_unlocked: bool = false

func _ready() -> void:
	GameState.particles = particle_manager
	screen_size = get_viewport().get_visible_rect().size

	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.timeout.connect(_spawn_object)
	spawn_timer.start()

	GameState.mass_changed.connect(_update_spawn_timer)
	GameState.skill_purchased.connect(_on_skill_purchased)

	# Reflect skill state on load (e.g. after save/load later).
	_nudge_unlocked = GameState.has_skill("mechanic_nudge")

# ── Input ────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		if _nudge_unlocked:
			queue_redraw()

	elif event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and _nudge_unlocked:
		_try_nudge(event.position)

# ── Draw ─────────────────────────────────────────────────────────────────────

func _draw() -> void:
	if not _nudge_unlocked:
		return
	draw_arc(mouse_pos, NUDGE_RADIUS, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.2), 1.0)

# ── Process ──────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	_update_debug()

# ── Nudge ────────────────────────────────────────────────────────────────────

func _try_nudge(click_pos: Vector2) -> void:
	for obj in active_objects:
		if not is_instance_valid(obj):
			continue
		if obj.position.distance_to(click_pos) <= NUDGE_RADIUS:
			obj.apply_nudge(NUDGE_STRENGTH)

# ── Spawn ────────────────────────────────────────────────────────────────────

func _spawn_object() -> void:
	active_objects = active_objects.filter(func(o): return is_instance_valid(o))
	if active_objects.size() >= MAX_OBJECTS:
		return

	var unlocked := GameState.get_unlocked_types()
	if unlocked.is_empty():
		return

	var obj: Node2D = SPACE_OBJECT_SCENE.instantiate()
	add_child(obj)
	obj.setup(_random_edge_position(), unlocked[randi() % unlocked.size()], black_hole.position)
	active_objects.append(obj)

func _random_edge_position() -> Vector2:
	match randi() % 4:
		0: return Vector2(randf() * screen_size.x, 0.0)
		1: return Vector2(randf() * screen_size.x, screen_size.y)
		2: return Vector2(0.0,          randf() * screen_size.y)
		_: return Vector2(screen_size.x, randf() * screen_size.y)

# ── Signals ──────────────────────────────────────────────────────────────────

func _update_spawn_timer() -> void:
	spawn_timer.wait_time = GameState.get_spawn_interval()

func _on_skill_purchased(id: int) -> void:
	var effect: String = SkillData.get_skill_node(id).get("effect", "")
	if effect == "mechanic_nudge":
		_nudge_unlocked = true
		queue_redraw()

# ── Debug ─────────────────────────────────────────────────────────────────────

func _update_debug() -> void:
	var counts: Dictionary = {}
	for obj in active_objects:
		if is_instance_valid(obj):
			counts[obj.obj_type] = counts.get(obj.obj_type, 0) + 1

	var lines := ["Active Objects:"]
	for type in counts:
		lines.append("%s: %d" % [type, counts[type]])
	debug_label.text = "\n".join(lines)
