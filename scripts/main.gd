extends Node2D

const SPACE_OBJECT_SCENE  := preload("res://scenes/space_object.tscn")
const FLOATING_TEXT_SCENE := preload("res://scripts/floating_text.gd")

@onready var black_hole:      Node2D = $BlackHole
@onready var spawn_timer:     Timer  = $SpawnTimer
@onready var debug_label:     Label  = $DebugLabel
@onready var particle_manager: Node2D = $ParticleManager

var _absorb_count:        int   = 0
var _absorb_timer:        float = 0.0
var _absorbs_per_min:     float = 0.0
var _avg_mass_per_absorb: float = 1.0
var _mass_at_last_sample: float = 0.0
var screen_size:          Vector2 = Vector2.ZERO
var active_objects:       Array   = []

# ── Flash state ───────────────────────────────────────────────────────────────
var _flash_alpha:   float = 0.0
var _flash_color:   Color = Color.WHITE
var _flash_node:    ColorRect

func _ready() -> void:
	GameState.particles = particle_manager
	screen_size = get_viewport().get_visible_rect().size

	GameState.load_game()

	spawn_timer.wait_time = GameState.get_spawn_interval()
	spawn_timer.timeout.connect(_spawn_object)
	spawn_timer.start()

	GameState.mass_changed.connect(_update_spawn_timer)
	GameState.skill_purchased.connect(_on_skill_purchased)
	GameState.object_absorbed_detail.connect(_on_absorbed_detail)

	# build flash overlay
	_flash_node = ColorRect.new()
	_flash_node.color = Color(1, 1, 1, 0)
	_flash_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_node.z_index = 100
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_flash_node.position = Vector2.ZERO
	_flash_node.size = vp
	add_child(_flash_node)

	GameState.energy = GameConfig.test_energy
	GameState.mass = GameConfig.test_mass
	GameState.emit_signal("energy_changed")
	GameState.emit_signal("mass_changed")

# ── Absorbed detail ───────────────────────────────────────────────────────────

func _on_absorbed_detail(
		pos: Vector2,
		mass_gained: float,
		color: Color,
		size: float,
		is_crit: bool) -> void:

	_absorb_count += 1
	_spawn_floating_text(pos, mass_gained, color, size, is_crit)
	_trigger_flash(color, is_crit)

# ── Floating text ─────────────────────────────────────────────────────────────

func _spawn_floating_text(
		pos: Vector2,
		mass_gained: float,
		color: Color,
		_size: float,
		is_crit: bool) -> void:

	var float_level: float = GameState.get_skill_value("float_numbers", 0.0)
	if float_level <= 0.0:
		return

	var script := FLOATING_TEXT_SCENE
	var node   := Node2D.new()
	node.set_script(script)
	add_child(node)

	var text:       String = ""
	var text_color: Color  = color.lightened(0.3)
	var text_size:  float  = 18.0 + float_level * 3.0

	if is_crit:
		text       = "CRIT! +%.1f" % mass_gained
		text_color = Color(1.0, 0.85, 0.1)
		text_size  = text_size + 10.0
	else:
		# only show numbers at level 2+
		if float_level >= 2.0:
			text = "+%.1f" % mass_gained
		else:
			text = "+"

	if text.is_empty():
		node.queue_free()
		return

	node.call("setup", pos, text, text_color, text_size)

# ── Screen flash ──────────────────────────────────────────────────────────────

func _trigger_flash(color: Color, is_crit: bool) -> void:
	var intensity: float = GameState.get_skill_value("flash_intensity", 0.0)
	if intensity <= 0.0:
		return
	var alpha: float = intensity * (2.0 if is_crit else 1.0)
	_flash_color = Color(color.r, color.g, color.b, clampf(alpha, 0.0, 0.6))
	_flash_alpha = _flash_color.a

# ── Process ───────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_flash(delta)
	_update_debug(delta)

func _update_flash(delta: float) -> void:
	if _flash_alpha <= 0.0:
		return
	_flash_alpha = maxf(0.0, _flash_alpha - delta * 4.0)
	_flash_node.color = Color(_flash_color.r, _flash_color.g, _flash_color.b, _flash_alpha)

# ── Spawn ─────────────────────────────────────────────────────────────────────

func _spawn_object() -> void:
	active_objects = active_objects.filter(func(o): return is_instance_valid(o))
	if active_objects.size() >= GameConfig.max_objects:
		return
	var unlocked: Array = GameState.get_unlocked_types()
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

# ── Signals ───────────────────────────────────────────────────────────────────

func _update_spawn_timer() -> void:
	spawn_timer.wait_time = GameState.get_spawn_interval()

func _on_skill_purchased(id: int) -> void:
	var level: int = GameState.get_skill_level(id)
	var data: Dictionary = SkillData.get_level_data(id, level)
	var effect: String = data.get("effect", "")
	# no nudge mechanic anymore — placeholder for future effects
	if effect == "mechanic_nudge":
		pass

# ── Debug ─────────────────────────────────────────────────────────────────────

func _update_debug(delta: float) -> void:
	_absorb_timer += delta

	if _absorb_timer >= GameConfig.debug_sample_window:
		_absorbs_per_min = (_absorb_count / _absorb_timer) * 60.0
		if _absorb_count > 0:
			var mass_gained: float = GameState.mass - _mass_at_last_sample
			_avg_mass_per_absorb = mass_gained / float(_absorb_count)
		_mass_at_last_sample = GameState.mass
		_absorb_count        = 0
		_absorb_timer        = 0.0

	var passive_rate: float = GameConfig.passive_pull_base + GameState.mass * GameConfig.passive_pull_scale
	var e:            float = GameState.elapsed_time
	var elapsed_str:  String = "%02d:%02d" % [int(e / 60), int(e) % 60]
	var eta_str:      String = "??:??"

	if _absorbs_per_min > 0.0:
		var mass_per_min: float = _absorbs_per_min * _avg_mass_per_absorb
		var mass_needed:  float = maxf(0.0, GameConfig.debug_eta_target_mass - GameState.mass)
		if mass_per_min > 0.0:
			var mins: float = mass_needed / mass_per_min
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
