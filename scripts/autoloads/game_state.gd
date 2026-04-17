# game_state.gd
# Autoload singleton — Project > Autoloads as "GameState"
extends Node

signal mass_changed

var mass: float = 0.0

# ── Upgrade levels ─────────────────────────────────────────────────
var levels: Dictionary = {
	"spawn": 0,
	"pull":  0,
	"multi": 0,
}

const BASE_COSTS: Dictionary = {
	"spawn": 10.0,
	"pull":  15.0,
	"multi": 25.0,
}

# ── Mass milestones that unlock object tiers ───────────────────────
# Keys are cumulative mass thresholds, values are the unlocked type list
const TIER_THRESHOLDS: Dictionary = {
	0.0:        ["asteroid"],
	500.0:      ["asteroid", "planet"],
	5000.0:     ["asteroid", "planet", "star"],
	30000.0:    ["asteroid", "planet", "star", "neutron_star"],
	80000.0:    ["asteroid", "planet", "star", "neutron_star", "starcluster"],
	150000.0:   ["asteroid", "planet", "star", "neutron_star", "starcluster", "nebula"],
	800000.0:   ["asteroid", "planet", "star", "neutron_star", "starcluster", "nebula", "galaxy"],
}

# ── Public API ─────────────────────────────────────────────────────
func add_mass(amount: float) -> void:
	mass += amount
	emit_signal("mass_changed")

func get_spawn_interval() -> float:
	return maxf(0.3, 2.0 - levels["spawn"] * 0.15)

func get_mass_multiplier() -> float:
	return 1.0 + levels["multi"] * 0.25

func get_upgrade_cost(which: String) -> float:
	return BASE_COSTS[which] * pow(1.15, levels[which])

func buy_upgrade(which: String) -> bool:
	var cost := get_upgrade_cost(which)
	if mass < cost:
		return false
	mass -= cost
	levels[which] += 1
	emit_signal("mass_changed")
	return true

func get_unlocked_types() -> Array:
	var result := ["asteroid"]
	for threshold in TIER_THRESHOLDS.keys():
		if mass >= threshold:
			result = TIER_THRESHOLDS[threshold]
	return result
