# skill_data.gd
# Autoload singleton — Project > Autoloads as "SkillData"
#
# Defines every skill tree node. Nothing here mutates — this is read-only
# reference data. GameState owns what's been purchased.
#
# Effect types and what consumes them:
#   "mechanic_nudge"  — main.gd gates nudge input behind has_skill()
#   "spiral_rate"     — space_object.gd reads get_skill_value()
#   "trail_length"    — space_object.gd reads get_skill_value()
#   "nudge_resist"    — space_object.gd reads get_skill_value()
#   "unlock_tier"     — game_state.get_unlocked_types() cross-references
#   "spawn_rate"      — game_state.get_spawn_interval() reads get_skill_value()
#   "energy_gain"     — space_object._absorb() reads get_skill_value()
#   "pull_strength"   — reserved for black hole pull logic
extends Node

const NODES: Dictionary = {
	# ── Root ────────────────────────────────────────────────────────────────
	1: {
		"label":   "Nudge",
		"desc":    "Unlock the ability to nudge objects into a death spiral.",
		"cost":    10.0,
		"prereqs": [],
		"effect":  "mechanic_nudge",
		"value":   1,
	},

	# ── Branch A: Spiral ────────────────────────────────────────────────────
	2: {
		"label":   "Faster Spiral",
		"desc":    "Nudged objects spiral inward 50% faster.",
		"cost":    20.0,
		"prereqs": [1],
		"effect":  "spiral_rate",
		"value":   90.0,        # replaces default SPIRAL_RATE of 60
	},
	5: {
		"label":   "Death Spiral",
		"desc":    "Spiral rate doubled. Objects have no escape.",
		"cost":    45.0,
		"prereqs": [2],
		"effect":  "spiral_rate",
		"value":   140.0,
	},

	# ── Branch B: Trail ─────────────────────────────────────────────────────
	3: {
		"label":   "Long Trail",
		"desc":    "Object trails grow twice as long.",
		"cost":    15.0,
		"prereqs": [1],
		"effect":  "trail_length",
		"value":   40,          # replaces MAX_TRAIL of 20
	},
	6: {
		"label":   "Comet Trail",
		"desc":    "Trails extended further and brighter.",
		"cost":    35.0,
		"prereqs": [3],
		"effect":  "trail_length",
		"value":   70,
	},

	# ── Branch C: Resistance ────────────────────────────────────────────────
	4: {
		"label":   "Weakened Resist",
		"desc":    "All objects are 30% less likely to resist nudges.",
		"cost":    25.0,
		"prereqs": [1],
		"effect":  "nudge_resist_reduction",
		"value":   0.3,
	},
	7: {
		"label":   "Broken Resist",
		"desc":    "Resistance is reduced by a further 50%.",
		"cost":    50.0,
		"prereqs": [4],
		"effect":  "nudge_resist_reduction",
		"value":   0.8,
	},

	# ── Convergence: Tier Unlock ─────────────────────────────────────────────
	8: {
		"label":   "Tier Unlock",
		"desc":    "Unlocks the next class of objects to spawn.",
		"cost":    80.0,
		"prereqs": [5, 6, 7],   # requires all three branch ends
		"effect":  "unlock_tier",
		"value":   1,           # GameState increments an unlock tier counter
	},

	# ── Branch D: Utility ───────────────────────────────────────────────────
	9: {
		"label":   "Spawn Surge",
		"desc":    "Objects spawn 25% faster.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "spawn_rate",
		"value":   0.75,        # multiplier on spawn interval
	},
	10: {
		"label":   "Energy Surge",
		"desc":    "Earn 50% more energy per absorption.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "energy_gain",
		"value":   1.5,         # multiplier on energy awarded
	},
	11: {
		"label":   "Pull Strength",
		"desc":    "Black hole absorbs objects at closer range.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "pull_strength",
		"value":   1.4,         # multiplier on pull zone size
	},

	# ── Endgame ─────────────────────────────────────────────────────────────
	12: {
		"label":   "Singularity",
		"desc":    "All systems at maximum. The end begins.",
		"cost":    200.0,
		"prereqs": [9, 10, 11],
		"effect":  "singularity",
		"value":   1,
	},
}

func get_skill_node(id: int) -> Dictionary:
	return NODES.get(id, {})

func get_all_ids() -> Array:
	return NODES.keys()
