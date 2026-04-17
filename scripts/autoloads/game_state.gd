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

func _compare_object_mass(a: String, b: String) -> bool:
	return ObjectData.DATA[a]["mass"] < ObjectData.DATA[b]["mass"]

func get_unlocked_types() -> Array:
	var all_types := ObjectData.DATA.keys()
	all_types.sort_custom(Callable(self, "_compare_object_mass"))

	var result: Array = []
	for type_name in all_types:
		if mass >= ObjectData.DATA[type_name]["mass"]:
			result.append(type_name)

	if result.is_empty():
		if all_types.size() > 0:
			result.append(all_types[0])
	return result
