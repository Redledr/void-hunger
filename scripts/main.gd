extends Node2D

const SPACE_OBJECT_SCENE := preload("res://scenes/space_object.tscn")

@onready var black_hole: Node2D = $BlackHole
@onready var spawn_timer: Timer = $SpawnTimer
@onready var debug_label: Label = $DebugLabel
@onready var particle_manager: Node2D = $ParticleManager

var _absorb_count: int = 0
var _absorb_timer: float = 0.0
var _absorbs_per_min: float = 0.0
var _avg_mass_per_absorb: float = 1.0
var _mass_at_last_sample: float = 0.0
var screen_size: Vector2 = Vector2.ZERO
var active_objects: Array = []
var mouse_pos: Vector2 = Vector2.ZERO
var test_energy: float = 0.0
var _nudge_unlocked: bool = false

func _ready() -> void:
	GameState.particles = particle_manager
	screen_size = get_viewport().get_visible_rect().size

	GameState.load_game()

	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.timeout.connect(_spawn_object)
	spawn_timer.start()

	GameState.mass_changed.connect(_update_spawn_timer)
	GameState.skill_purchased.connect(_on_skill_purchased)
	GameState.object_absorbed.connect(register_absorption)

	print("test_energy value: ", GameConfig.test_energy)
	GameState.energy = GameConfig.test_energy
	GameState.emit_signal("energy_changed")
	print("energy after set: ", GameState.energy)
	
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
	draw_arc(mouse_pos, GameConfig.nudge_radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.2), 1.0)

# ── Process ──────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_debug(delta)

# ── Nudge ────────────────────────────────────────────────────────────────────

func _try_nudge(click_pos: Vector2) -> void:
	for obj in active_objects:
		if not is_instance_valid(obj):
			continue
		if obj.position.distance_to(click_pos) <= GameConfig.nudge_radius:
			obj.apply_nudge(GameConfig.nudge_strength)

# ── Spawn ────────────────────────────────────────────────────────────────────

func _spawn_object() -> void:
	active_objects = active_objects.filter(func(o): return is_instance_valid(o))
	if active_objects.size() >= GameConfig.max_objects:
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
		2: return Vector2(0.0, randf() * screen_size.y)
		_: return Vector2(screen_size.x, randf() * screen_size.y)

# ── Signals ──────────────────────────────────────────────────────────────────

func _update_spawn_timer() -> void:
	spawn_timer.wait_time = GameState.get_spawn_interval()

func _on_skill_purchased(id: int) -> void:
	var effect: String = SkillData.get_skill_node(id).get("effect", "")
	if effect == "mechanic_nudge":
		_nudge_unlocked = true
		queue_redraw()

func register_absorption() -> void:
	_absorb_count += 1

# ── Debug ─────────────────────────────────────────────────────────────────────

func _update_debug(delta: float) -> void:
	_absorb_timer += delta

	if _absorb_timer >= GameConfig.debug_sample_window:
		_absorbs_per_min = (_absorb_count / _absorb_timer) * 60.0
		if _absorb_count > 0:
			var mass_gained := GameState.mass - _mass_at_last_sample
			_avg_mass_per_absorb = mass_gained / float(_absorb_count)
		_mass_at_last_sample = GameState.mass
		_absorb_count = 0
    	_absorb_timer = 0.0

	var passive_rate := GameConfig.passive_pull_base + GameState.mass * GameConfig.passive_pull_scale

	var e := GameState.elapsed_time
	var elapsed_str := "%02d:%02d" % [int(e / 60), int(e) % 60]

	var eta_str := "??:??"
	if _absorbs_per_min > 0.0:
		var mass_per_min := _absorbs_per_min * _avg_mass_per_absorb
		var mass_needed := maxf(0.0, GameConfig.debug_eta_target_mass - GameState.mass)
		if mass_per_min > 0.0:
			var mins := mass_needed / mass_per_min
			eta_str = "%02d:%02d" % [int(mins), int(mins * 60.0) % 60]

	var counts: Dictionary = {}
	for obj in active_objects:
		if is_instance_valid(obj):
			counts[obj.obj_type] = counts.get(obj.obj_type, 0) + 1

	var lines: Array = [
		"── debug ──",
		"time:    %s" % elapsed_str,
		"eta mid: %s" % eta_str,
		"mass:    %.1f" % GameState.mass,
		"energy:  %.1f" % GameState.energy,
		"pull/s:  %.2f" % passive_rate,
		"abs/min: %.1f" % _absorbs_per_min,
		"objects: %d / %d" % [active_objects.filter(func(o): return is_instance_valid(o)).size(), GameConfig.max_objects],
		"──────────",
	]
	for type in counts:
		lines.append("  %s: %d" % [type, counts[type]])

	debug_label.text = "\n".join(lines)
