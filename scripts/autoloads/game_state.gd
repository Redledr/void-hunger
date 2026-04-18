# game_state.gd
# Autoload singleton — Project > Autoloads as "GameState"
extends Node

signal mass_changed
signal energy_changed
signal skill_purchased(id: int)

var mass:     float = 0.0
var energy:   float = 0.0

# Set by main.gd on _ready. Any script can call GameState.particles.burst().
var particles: Node = null

# Tracks which skill IDs have been purchased.
var unlocked_skills: Dictionary = {}

# ── Mass ────────────────────────────────────────────────────────────────────

func add_mass(amount: float) -> void:
	mass += amount
	emit_signal("mass_changed")

# ── Energy ──────────────────────────────────────────────────────────────────

func add_energy(amount: float) -> void:
	energy += amount * get_skill_value("energy_gain", 1.0)
	emit_signal("energy_changed")

# ── Skills ──────────────────────────────────────────────────────────────────

func has_skill(effect: String) -> bool:
	for id in unlocked_skills:
		var node := SkillData.get_skill_node(id)
		if node.get("effect", "") == effect:
			return true
	return false

# Returns the value of the highest-tier purchased skill with the given effect,
# or default_val if no such skill has been purchased.
func get_skill_value(effect: String, default_val: float) -> float:
	var best := default_val
	for id in unlocked_skills:
		var node := SkillData.get_skill_node(id)
		if node.get("effect", "") == effect:
			var v: float = float(node.get("value", default_val))
			# For reductions, higher value = more reduced, so take max.
			# For rates/lengths, higher value = stronger, so take max.
			best = maxf(best, v)
	return best

func can_buy_skill(id: int) -> bool:
	if unlocked_skills.has(id):
		return false
	var node := SkillData.get_skill_node(id)
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
	return true

# ── Spawn helpers ────────────────────────────────────────────────────────────

func get_spawn_interval() -> float:
	var multiplier := get_skill_value("spawn_rate", 1.0)
	return maxf(0.3, 2.0 * multiplier)

func get_mass_multiplier() -> float:
	return 1.0 + get_skill_value("mass_multi", 0.0)

# ── Object unlock ────────────────────────────────────────────────────────────
#
# Types become spawnable when the player's mass is in a sensible window.
# "unlock_tier" skills extend that window upward over time.

func get_unlocked_types() -> Array:
	var sorted := ObjectData.get_sorted_types()
	if sorted.is_empty():
		return []

	var tier_bonus: float = get_skill_value("unlock_tier", 0.0)
	# Window: spawn objects between 20% and 500% of current mass.
	# Tier unlock skill widens the upper bound gradually.
	var lower_bound: float = mass * 0.2
	var upper_bound: float = mass * (5.0 + tier_bonus * 2.0)

	var result: Array = []
	for type_name in sorted:
		var obj_mass: float = ObjectData.DATA[type_name]["mass"]
		if obj_mass >= lower_bound and obj_mass <= upper_bound:
			result.append(type_name)

	# Only fall back to lightest type if mass is so low nothing fits the window.
	# Once mass grows enough to have valid entries, quarks never appear again.
	if result.is_empty():
		result.append(sorted[0])

	return result

func _compare_object_mass(a: String, b: String) -> bool:
	return ObjectData.DATA[a]["mass"] < ObjectData.DATA[b]["mass"]
