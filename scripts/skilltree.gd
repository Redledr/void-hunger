extends CanvasLayer

@onready var overlay:        ColorRect       = $Overlay
@onready var energy_label:   Label           = $Overlay/Panel/VBox/Header/EnergyLabel
@onready var close_button:   Button          = $Overlay/Panel/VBox/Header/CloseButton
@onready var node_container: VBoxContainer   = $Overlay/Panel/VBox/Scroll/NodeContainer

# Holds references to each skill row so we can refresh them cheaply.
var _rows: Dictionary = {}

func _ready() -> void:
	hide()   # starts hidden — shown on demand

	close_button.pressed.connect(hide_tree)
	GameState.energy_changed.connect(_refresh_energy)
	GameState.skill_purchased.connect(_on_skill_purchased)

	_build_tree()
	_refresh_energy()

# ── Public API ───────────────────────────────────────────────────────────────

func show_tree() -> void:
	_refresh_all_rows()
	show()
	get_tree().paused = true

func hide_tree() -> void:
	hide()
	get_tree().paused = false

# ── Build ─────────────────────────────────────────────────────────────────────
# Creates one row per skill node. Rows are grouped by depth so prerequisites
# read top-to-bottom without needing a canvas layout.

func _build_tree() -> void:
	# Group node IDs by their depth (longest prereq chain).
	var depths := _compute_depths()
	var by_depth: Dictionary = {}
	for id in depths:
		var d: int = depths[id]
		if not by_depth.has(d):
			by_depth[d] = []
		by_depth[d].append(id)

	var sorted_depths := by_depth.keys()
	sorted_depths.sort()

	for depth in sorted_depths:
		# Separator label showing tier.
		var sep := Label.new()
		sep.text = "── Tier %d ──" % (depth + 1)
		sep.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		node_container.add_child(sep)

		# Sort IDs within tier for stable ordering.
		var ids: Array = by_depth[depth]
		ids.sort()
		for id in ids:
			node_container.add_child(_make_row(id))

func _make_row(id: int) -> HBoxContainer:
	var data := SkillData.get_skill_node(id)

	var row := HBoxContainer.new()
	row.name = "Row_%d" % id

	# Buy button.
	var btn := Button.new()
	btn.name         = "Btn"
	btn.custom_minimum_size = Vector2(160, 36)
	btn.pressed.connect(_on_buy_pressed.bind(id))
	row.add_child(btn)

	# Description label.
	var lbl := Label.new()
	lbl.name              = "Desc"
	lbl.text              = "%s\n%s" % [data.get("desc", ""), _prereq_text(id)]
	lbl.autowrap_mode     = TextServer.AUTOWRAP_WORD
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	row.add_child(lbl)

	_rows[id] = row
	_refresh_row(id)
	return row

# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh_energy() -> void:
	energy_label.text = "Energy: %s" % snapped(GameState.energy, 0.1)
	_refresh_all_rows()

func _refresh_all_rows() -> void:
	for id in _rows:
		_refresh_row(id)

func _refresh_row(id: int) -> void:
	if not _rows.has(id):
		return

	var row  := _rows[id] as HBoxContainer
	var btn  := row.get_node("Btn")  as Button
	var data := SkillData.get_skill_node(id)
	var cost := float(data.get("cost", 0.0))

	if GameState.unlocked_skills.has(id):
		btn.text     = "✓ %s" % data.get("label", str(id))
		btn.disabled = true
		btn.modulate = Color(0.3, 0.9, 0.4)
	elif GameState.can_buy_skill(id):
		btn.text     = "%s\n[%s E]" % [data.get("label", str(id)), snapped(cost, 0.1)]
		btn.disabled = false
		btn.modulate = Color(1.0, 1.0, 1.0)
	else:
		btn.text     = "🔒 %s\n[%s E]" % [data.get("label", str(id)), snapped(cost, 0.1)]
		btn.disabled = true
		btn.modulate = Color(0.4, 0.4, 0.45)

func _on_skill_purchased(id: int) -> void:
	_refresh_row(id)
	# Refresh siblings — purchasing may unlock their prereqs.
	for other_id in _rows:
		if id in SkillData.get_skill_node(other_id).get("prereqs", []):
			_refresh_row(other_id)

# ── Input ─────────────────────────────────────────────────────────────────────

func _on_buy_pressed(id: int) -> void:
	GameState.buy_skill(id)

func _unhandled_input(event: InputEvent) -> void:
	# Let Escape close the tree.
	if visible and event.is_action_pressed("ui_cancel"):
		hide_tree()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _prereq_text(id: int) -> String:
	var prereqs: Array = SkillData.get_skill_node(id).get("prereqs", [])
	if prereqs.is_empty():
		return ""
	var names := prereqs.map(func(p): return SkillData.get_skill_node(p).get("label", str(p)))
	return "Requires: %s" % ", ".join(names)

# Computes the depth of each node (longest path from root).
# Depth 0 = no prerequisites.
func _compute_depths() -> Dictionary:
	var depths: Dictionary = {}
	for id in SkillData.get_all_ids():
		_depth_of(id, depths)
	return depths

func _depth_of(id: int, cache: Dictionary) -> int:
	if cache.has(id):
		return cache[id]
	var prereqs: Array = SkillData.get_skill_node(id).get("prereqs", [])
	if prereqs.is_empty():
		cache[id] = 0
		return 0
	var max_parent := 0
	for p in prereqs:
		max_parent = maxi(max_parent, _depth_of(p, cache))
	cache[id] = max_parent + 1
	return cache[id]
