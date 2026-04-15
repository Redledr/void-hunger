# game_state.gd
# Autoload (singleton) — add to Project > Autoloads as "GameState"
#
# Owns all persistent gameplay numbers.  Nothing else should write
# to mass or upgrade levels directly; go through the public API here
# so the mass_changed signal always fires reliably.
extends Node

signal mass_changed

var mass: float = 0.0

# Levels stored in a dictionary so we never use fragile string-property
# access (get/set with a typo would silently return null before).
var levels: Dictionary = {
	"spawn": 0,
	"pull":  0,
	"multi": 0,
}

# ── Base upgrade costs ─────────────────────────────────────────────
const BASE_COSTS: Dictionary = {
	"spawn": 10.0,
	"pull":  15.0,
	"multi": 25.0,
}

# ── Public API ─────────────────────────────────────────────────────

func add_mass(amount: float) -> void:
	mass += amount
	emit_signal("mass_changed")

func get_spawn_interval() -> float:
	# Floor at 0.3 s so the game never locks up at high spawn levels.
	return maxf(0.3, 2.0 - levels["spawn"] * 0.15)

func get_pull_speed() -> float:
	return 60.0 + levels["pull"] * 20.0

func get_mass_multiplier() -> float:
	return 1.0 + levels["multi"] * 0.25

func get_upgrade_cost(which: String) -> float:
	return BASE_COSTS[which] * pow(1.15, levels[which])

# Returns true when the purchase succeeds, false when the player
# cannot afford it.  Callers can use the return value for feedback.
func buy_upgrade(which: String) -> bool:
	var cost := get_upgrade_cost(which)
	if mass < cost:
		return false
	mass -= cost
	levels[which] += 1
	emit_signal("mass_changed")
	return true

# Convenience: which object types are unlocked at the current pull level.
# Keeping this here (instead of main.gd) means any future spawner can
# call it without duplicating the tier logic.
func get_unlocked_types() -> Array:
	var all_types := ["asteroid", "planet", "star", "neutron_star"]
	if levels["pull"] >= 10:
		return all_types
	elif levels["pull"] >= 6:
		return all_types.slice(0, 3)
	elif levels["pull"] >= 3:
		return all_types.slice(0, 2)
	return ["asteroid"]
