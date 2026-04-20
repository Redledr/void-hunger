# object_data.gd
# Autoload singleton — Project > Autoloads as "ObjectData"
#
# Loads from res://data/object_data.csv, auto-downloaded from Google Sheets.
# CSV columns: key, display_name, mass, size, color_r, color_g, color_b, nudge_resist
#
# To change values: edit the Google Sheet, hit Play. No code changes needed.
extends Node

var DATA: Dictionary = {}
var _sorted_types: Array = []

func _ready() -> void:
	_load_csv()
	_sorted_types = DATA.keys()
	_sorted_types.sort_custom(func(a, b): return DATA[a]["mass"] < DATA[b]["mass"])

func _load_csv() -> void:
	const PATH := "res://data/object_data.csv"

	if not FileAccess.file_exists(PATH):
		push_error("ObjectData: %s not found." % PATH)
		return

	var file := FileAccess.open(PATH, FileAccess.READ)
	if not file:
		push_error("ObjectData: could not open %s" % PATH)
		return

	file.get_csv_line()  # skip header row

	while not file.eof_reached():
		var c: PackedStringArray = file.get_csv_line()

		if c.size() == 0:
			continue

		if c.size() < 8:
			push_warning("Skipping malformed row: %s" % c)
			continue

		var key := c[0].strip_edges()
		if key.is_empty():
			continue

		DATA[key] = {
			"display_name": c[1].strip_edges(),
			"mass": float(c[2].strip_edges()),
			"size": int(c[3].strip_edges()),
			"color": Color(
				float(c[4].strip_edges()),
				float(c[5].strip_edges()),
				float(c[6].strip_edges())
			),
			"nudge_resist": float(c[7].strip_edges()),
		}

	file.close()

	print("ObjectData: loaded %d types" % DATA.size())
	print(JSON.stringify(DATA, "\t"))

func get_data(type: String) -> Dictionary:
	return DATA.get(type, {})

func get_sorted_types() -> Array:
	return _sorted_types

func get_sorted_index(type: String) -> int:
	return _sorted_types.find(type)
