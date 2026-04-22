# game_state.gd
# Autoload singleton — Project > Autoloads as "GameState"
extends Node

signal mass_changed
signal energy_changed
signal skill_purchased(id: int)
signal object_absorbed
@warning_ignore("unused_signal")
signal object_absorbed_detail(pos: Vector2, mass_gained: float, color: Color, size: float, is_crit: bool)

var mass:         float = 0.0
var energy:       float = 0.0
var elapsed_time: float = 0.0
var particles:    Node  = null

var skill_levels: Dictionary = {}
# { skill_id: current_level }
# absent = never bought

const SAVE_PATH := "user://savegame.cfg"

func _process(delta: float) -> void:
	elapsed_time += delta

# ── Mass ─────────────────────────────────────────────────────────────────────

func add_mass(amount: float) -> void:
	mass += amount
	emit_signal("mass_changed")
	emit_signal("object_absorbed")

# ── Energy ────────────────────────────────────────────────────────────────────

func add_energy(amount: float) -> void:
	energy += amount * get_skill_value("energy_gain", 1.0)
	emit_signal("energy_changed")

# ── Skills ────────────────────────────────────────────────────────────────────

func get_skill_level(id: int) -> int:
	return skill_levels.get(id, 0)

func can_upgrade_skill(id: int) -> bool:
	var current  := get_skill_level(id)
	var next     := current + 1
	if next > SkillData.get_max_level(id):
		return false
	var data := SkillData.get_level_data(id, next)
	if data.is_empty():
		return false
	if energy < float(data.get("cost_energy", INF)):
		return false
	if mass < float(data.get("unlock_mass", INF)):
		return false
	return true

func is_skill_mass_locked(id: int) -> bool:
	var next := get_skill_level(id) + 1
	if next > SkillData.get_max_level(id):
		return false
	var data := SkillData.get_level_data(id, next)
	if data.is_empty():
		return false
	return mass < float(data.get("unlock_mass", 0.0))

func upgrade_skill(id: int) -> bool:
	if not can_upgrade_skill(id):
		return false
	var next := get_skill_level(id) + 1
	var data := SkillData.get_level_data(id, next)
	energy          -= float(data.get("cost_energy", 0.0))
	skill_levels[id] = next
	emit_signal("energy_changed")
	emit_signal("skill_purchased", id)
	save_game()
	return true

func get_skill_value(effect: String, default_val: float) -> float:
	var best := default_val
	for id in skill_levels:
		var data := SkillData.get_level_data(id, skill_levels[id])
		if data.get("effect", "") == effect:
			best = maxf(best, float(data.get("value", default_val)))
	return best

func has_skill(effect: String) -> bool:
	for id in skill_levels:
		var data := SkillData.get_level_data(id, skill_levels[id])
		if data.get("effect", "") == effect:
			return true
	return false

# ── Spawn helpers ─────────────────────────────────────────────────────────────

func get_spawn_interval() -> float:
	var multiplier := get_skill_value("spawn_rate", 1.0)
	return maxf(GameConfig.spawn_interval_min, GameConfig.spawn_interval_base * multiplier)

func get_mass_multiplier() -> float:
	return 1.0 + get_skill_value("mass_multi", 0.0)

# ── Object unlock ─────────────────────────────────────────────────────────────

func get_unlocked_types() -> Array:
	var sorted := ObjectData.get_sorted_types()
	if sorted.is_empty():
		return []

	var tier_bonus:  float = get_skill_value("unlock_tier", 0.0)
	var lower_bound: float = maxf(GameConfig.spawn_mass_lower_floor, mass * GameConfig.spawn_mass_lower_mult)
	var upper_bound: float = maxf(GameConfig.spawn_mass_upper_floor, mass * (GameConfig.spawn_mass_upper_mult + tier_bonus * GameConfig.spawn_tier_bonus_scalar))

	var result: Array = []
	for type_name in sorted:
		var obj_mass: float = ObjectData.DATA[type_name]["mass"]
		if obj_mass >= lower_bound and obj_mass <= upper_bound:
			result.append(type_name)

	if result.is_empty():
		result.append(sorted[0])

	return result

# ── Save / Load ───────────────────────────────────────────────────────────────

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "mass",         mass)
	cfg.set_value("game", "energy",       energy)
	cfg.set_value("game", "elapsed_time", elapsed_time)
	var flat: Array = []
	for id in skill_levels:
		flat.append(id)
		flat.append(skill_levels[id])
	cfg.set_value("game", "skill_levels", flat)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("GameState: failed to save (%d)" % err)

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	mass         = float(cfg.get_value("game", "mass",         0.0))
	energy       = float(cfg.get_value("game", "energy",       0.0))
	elapsed_time = float(cfg.get_value("game", "elapsed_time", 0.0))
	skill_levels.clear()
	var flat: Array = cfg.get_value("game", "skill_levels", [])
	var i := 0
	while i + 1 < flat.size():
		skill_levels[int(flat[i])] = int(flat[i + 1])
		i += 2
	emit_signal("mass_changed")
	emit_signal("energy_changed")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	mass         = 0.0
	energy       = 0.0
	elapsed_time = 0.0
	skill_levels.clear()
	emit_signal("mass_changed")
	emit_signal("energy_changed")
