# game_state.gd
# Autoload singleton — Project > Autoloads as "GameState"
extends Node

signal mass_changed
signal energy_changed
signal skill_purchased(id: int)
signal object_absorbed

var mass: float = 0.0
var energy: float = 0.0
var elapsed_time: float = 0.0
var particles: Node = null
var unlocked_skills: Dictionary = {}

const SAVE_PATH := "user://savegame.cfg"

func _process(delta: float) -> void:
	elapsed_time += delta

# ── Mass ────────────────────────────────────────────────────────────────────

func add_mass(amount: float) -> void:
	mass += amount
	emit_signal("mass_changed")
	emit_signal("object_absorbed")

# ── Energy ──────────────────────────────────────────────────────────────────

func add_energy(amount: float) -> void:
	energy += amount * get_skill_value("energy_gain", 1.0)
	emit_signal("energy_changed")

# ── Skills ──────────────────────────────────────────────────────────────────

func has_skill(effect: String) -> bool:
	for id in unlocked_skills:
		var node: Dictionary = SkillData.get_skill_node(id)
		if node.get("effect", "") == effect:
			return true
	return false

func get_skill_value(effect: String, default_val: float) -> float:
	var best := default_val
	for id in unlocked_skills:
		var node: Dictionary = SkillData.get_skill_node(id)
		if node.get("effect", "") == effect:
			var v: float = float(node.get("value", default_val))
			best = maxf(best, v)
	return best

func can_buy_skill(id: int) -> bool:
	if unlocked_skills.has(id):
		return false
	var node: Dictionary = SkillData.get_skill_node(id)
	if node.is_empty():
		return false
	if energy < float(node.get("cost", INF)):
		return false
	for prereq in node.get("prereqs", []):
		if not unlocked_skills.has(prereq):
			return false
	return true

func buy_skill(id: int) -> bool:
	if not can_buy_skill(id):
		return false
	var cost := float(SkillData.get_skill_node(id).get("cost", 0.0))
	energy -= cost
	unlocked_skills[id] = true
	emit_signal("energy_changed")
	emit_signal("skill_purchased", id)
	save_game()
	return true

# ── Spawn helpers ────────────────────────────────────────────────────────────

func get_spawn_interval() -> float:
	var multiplier := get_skill_value("spawn_rate", 1.0)
	return maxf(0.3, 2.0 * multiplier)

func get_mass_multiplier() -> float:
	return 1.0 + get_skill_value("mass_multi", 0.0)

# ── Object unlock ────────────────────────────────────────────────────────────

func get_unlocked_types() -> Array:
	var sorted := ObjectData.get_sorted_types()
	if sorted.is_empty():
		return []

	var tier_bonus: float = get_skill_value("unlock_tier", 0.0)
	var lower_bound: float = maxf(0.05, mass * 0.2)
	var upper_bound: float = maxf(2.0, mass * (5.0 + tier_bonus * 2.0))

	var result: Array = []
	for type_name in sorted:
		var obj_mass: float = ObjectData.DATA[type_name]["mass"]
		if obj_mass >= lower_bound and obj_mass <= upper_bound:
			result.append(type_name)

	if result.is_empty():
		result.append(sorted[0])

	return result

# ── Save / Load ──────────────────────────────────────────────────────────────

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "mass", mass)
	cfg.set_value("game", "energy", energy)
	cfg.set_value("game", "elapsed_time", elapsed_time)
	cfg.set_value("game", "unlocked_skills", unlocked_skills.keys())
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("GameState: failed to save (%d)" % err)

func load_game() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		# No save file yet — start fresh, that's fine.
		return

	mass = float(cfg.get_value("game", "mass", 0.0))
	energy = float(cfg.get_value("game", "energy", 0.0))
	elapsed_time = float(cfg.get_value("game", "elapsed_time", 0.0))

	unlocked_skills.clear()
	var ids: Array = cfg.get_value("game", "unlocked_skills", [])
	for id in ids:
		unlocked_skills[int(id)] = true

	emit_signal("mass_changed")
	emit_signal("energy_changed")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	mass = 0.0
	energy = 0.0
	unlocked_skills.clear()
	emit_signal("mass_changed")
	emit_signal("energy_changed")
