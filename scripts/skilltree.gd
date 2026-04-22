# skilltree.gd
extends CanvasLayer

@onready var overlay:        ColorRect     = $Overlay
@onready var energy_label:   Label         = $Overlay/Panel/VBox/Header/EnergyLabel
@onready var mass_label:     Label         = $Overlay/Panel/VBox/Header/MassLabel
@onready var close_button:   Button        = $Overlay/Panel/VBox/Header/CloseButton
@onready var node_container: VBoxContainer = $Overlay/Panel/VBox/Scroll/NodeContainer

var _rows: Dictionary = {}

func _ready() -> void:
	hide()
	close_button.pressed.connect(hide_tree)
	GameState.energy_changed.connect(_refresh_header)
	GameState.mass_changed.connect(_on_mass_changed)
	GameState.skill_purchased.connect(_on_skill_purchased)
	_build_tree()
	_refresh_header()

# ── Public API ────────────────────────────────────────────────────────────────

func show_tree() -> void:
	_refresh_all_rows()
	show()
	get_tree().paused = true

func hide_tree() -> void:
	hide()
	get_tree().paused = false

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_tree() -> void:
	var branches: Dictionary = {}
	for id in SkillData.get_all_ids():
		var branch: String = SkillData.get_skill(id).get("branch", "misc")
		if not branches.has(branch):
			branches[branch] = []
		branches[branch].append(id)

	for branch in branches:
		var header := Label.new()
		header.text = "── %s ──" % branch.to_upper()
		header.add_theme_color_override("font_color", Color(0.6, 0.5, 0.9))
		node_container.add_child(header)

		var ids: Array = branches[branch]
		ids.sort()
		for id in ids:
			node_container.add_child(_make_row(id))

func _make_row(id: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "Row_%d" % id

	# Upgrade button
	var btn := Button.new()
	btn.name = "Btn"
	btn.custom_minimum_size = Vector2(180, 40)
	btn.pressed.connect(_on_upgrade_pressed.bind(id))
	row.add_child(btn)

	# Info label
	var lbl := Label.new()
	lbl.name = "Info"
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	row.add_child(lbl)

	_rows[id] = row
	_refresh_row(id)
	return row

# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh_header() -> void:
	energy_label.text = "Energy: %s" % snapped(GameState.energy, 0.1)
	mass_label.text   = "Mass: %s"   % snapped(GameState.mass,   0.1)

func _refresh_all_rows() -> void:
	for id in _rows:
		_refresh_row(id)

func _refresh_row(id: int) -> void:
	if not _rows.has(id):
		return

	var row          := _rows[id] as HBoxContainer
	var btn          := row.get_node("Btn")  as Button
	var lbl          := row.get_node("Info") as Label
	var skill:        Dictionary = SkillData.get_skill(id)
	var current:      int        = GameState.get_skill_level(id)
	var max_level:    int        = SkillData.get_max_level(id)
	var label:        String     = skill.get("label", str(id))

	# Build pip string  ■■□□
	var pips := ""
	for i in range(max_level):
		pips += "■" if i < current else "□"

	if current >= max_level:
		# Fully maxed
		btn.text     = "%s\n%s MAX" % [label, pips]
		btn.disabled = true
		btn.modulate = Color(0.3, 0.9, 0.4)
		lbl.text     = "Fully upgraded."
	else:
		var next_data: Dictionary = SkillData.get_level_data(id, current + 1)
		var cost_e: int           = int(next_data.get("cost_energy", 0))
		var req_mass: float       = float(next_data.get("unlock_mass", 0.0))
		var locked: bool          = GameState.is_skill_mass_locked(id)
		var affordable: bool      = GameState.can_upgrade_skill(id)

		btn.text = "%s\n%s L%d→%d" % [label, pips, current, current + 1]

		if locked:
			btn.disabled = true
			btn.modulate = Color(0.35, 0.35, 0.4)
			lbl.text     = "Requires %.0f mass\nCosts %d energy" % [req_mass, cost_e]
		elif affordable:
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0)
			lbl.text     = "Costs %d energy" % cost_e
		else:
			btn.disabled = true
			btn.modulate = Color(0.5, 0.4, 0.4)
			lbl.text     = "Need %d energy (have %.0f)\nRequires %.0f mass" \
							% [cost_e, GameState.energy, req_mass]

# ── Input ─────────────────────────────────────────────────────────────────────

func _on_upgrade_pressed(id: int) -> void:
	GameState.upgrade_skill(id)

func _on_skill_purchased(id: int) -> void:
	_refresh_row(id)
	_refresh_header()

func _on_mass_changed() -> void:
	if visible:
		_refresh_all_rows()
		_refresh_header()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_tree()
