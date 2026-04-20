# skill_data.gd
# Autoload singleton — Project > Autoloads as "SkillData"
#
# Skill structure (prereqs, effects) lives here as source of truth.
# Cost and value are patched at startup from res://data/skill_data.csv,
# auto-downloaded from Google Sheets.
#
# To change costs/values: edit the Google Sheet, hit Play.
# To change structure (prereqs, effects): edit NODES below.
extends Node

var NODES: Dictionary = {
	1: {
		"label":   "Nudge",
		"desc":    "Unlock the ability to nudge objects into a death spiral.",
		"cost":    10.0,
		"prereqs": [],
		"effect":  "mechanic_nudge",
		"value":   1,
	},
	2: {
		"label":   "Faster Spiral",
		"desc":    "Nudged objects spiral inward 50% faster.",
		"cost":    20.0,
		"prereqs": [1],
		"effect":  "spiral_rate",
		"value":   90.0,
	},
	5: {
		"label":   "Death Spiral",
		"desc":    "Spiral rate doubled. Objects have no escape.",
		"cost":    45.0,
		"prereqs": [2],
		"effect":  "spiral_rate",
		"value":   140.0,
	},
	3: {
		"label":   "Long Trail",
		"desc":    "Object trails grow twice as long.",
		"cost":    15.0,
		"prereqs": [1],
		"effect":  "trail_length",
		"value":   40,
	},
	6: {
		"label":   "Comet Trail",
		"desc":    "Trails extended further and brighter.",
		"cost":    35.0,
		"prereqs": [3],
		"effect":  "trail_length",
		"value":   70,
	},
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
	8: {
		"label":   "Tier Unlock",
		"desc":    "Unlocks the next class of objects to spawn.",
		"cost":    80.0,
		"prereqs": [5, 6, 7],
		"effect":  "unlock_tier",
		"value":   1,
	},
	9: {
		"label":   "Spawn Surge",
		"desc":    "Objects spawn 25% faster.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "spawn_rate",
		"value":   0.75,
	},
	10: {
		"label":   "Energy Surge",
		"desc":    "Earn 50% more energy per absorption.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "energy_gain",
		"value":   1.5,
	},
	11: {
		"label":   "Pull Strength",
		"desc":    "Black hole absorbs objects at closer range.",
		"cost":    40.0,
		"prereqs": [8],
		"effect":  "pull_strength",
		"value":   1.4,
	},
	12: {
		"label":   "Singularity",
		"desc":    "All systems at maximum. The end begins.",
		"cost":    200.0,
		"prereqs": [9, 10, 11],
		"effect":  "singularity",
		"value":   1,
	},
}

func _ready() -> void:
	_apply_csv()

func _apply_csv() -> void:
	const PATH := "res://data/skill_data.csv"

	if not FileAccess.file_exists(PATH):
		push_warning("SkillData: %s not found, using hardcoded values." % PATH)
		return

	var file := FileAccess.open(PATH, FileAccess.READ)
	if not file:
		push_error("SkillData: could not open %s" % PATH)
		return

	file.get_line()  # skip header

	var patched := 0
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var c := line.split(",")
		if c.size() < 4:
			continue
		var id    := int(c[0])
		var cost  := float(c[2])
		var value := float(c[3])
		if NODES.has(id):
			NODES[id]["cost"]  = cost
			NODES[id]["value"] = value
			patched += 1
		else:
			push_warning("SkillData: CSV has id %d but no matching NODES entry" % id)

	file.close()
	print("SkillData: patched %d skills from CSV" % patched)

func get_skill_node(id: int) -> Dictionary:
	return NODES.get(id, {})

func get_all_ids() -> Array:
	return NODES.keys()