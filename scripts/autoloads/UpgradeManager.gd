# UpgradeManager.gd - Autoload
# Register in Project > Project Settings > Autoload as "UpgradeManager"
# Load order: EventBus > GameState > UpgradeManager

extends Node

var all_upgrades: Array[Dictionary] = []
var purchased_upgrades: Dictionary = {}  # upgrade_id -> true
var active_effects: Dictionary = {}

func _ready() -> void:
	active_effects["breaker_damage"] = 1.0
	active_effects["breaker_radius"] = 40
	active_effects["attack_speed"] = 0.5
	active_effects["object_value"] = 1.0
	print("UpgradeManager initialized")

func is_upgrade_available(upgrade_id: String) -> bool:
	var upgrade = find_upgrade(upgrade_id)
	if upgrade.is_empty():
		return false
	if GameState.get_currency() < upgrade.get("cost", 0):
		return false
	for prereq_id in upgrade.get("prereq_ids", []):
		if not purchased_upgrades.has(prereq_id):
			return false
	return true

func has_purchased(upgrade_id: String) -> bool:
	return purchased_upgrades.has(upgrade_id)

func buy_upgrade(upgrade_id: String) -> bool:
	var upgrade = find_upgrade(upgrade_id)
	if upgrade.is_empty():
		push_error("Tried to buy non-existent upgrade: " + upgrade_id)
		return false
	if purchased_upgrades.has(upgrade_id):
		push_warning("Already purchased: " + upgrade_id)
		return false
	for prereq_id in upgrade.get("prereq_ids", []):
		if not purchased_upgrades.has(prereq_id):
			push_error("Missing prerequisite: " + prereq_id)
			return false

	GameState.add_currency(-upgrade.get("cost", 0))
	purchased_upgrades[upgrade_id] = true
	apply_effect(upgrade)
	EventBus.upgrade_purchased.emit(upgrade_id)
	print("Purchased: " + str(upgrade.get("label", "Unknown")))
	return true

func apply_effect(upgrade: Dictionary) -> void:
	var effect_type: String = upgrade.get("effect_type", "")
	var effect_value: float = upgrade.get("effect_value", 1.0)
	var base_value: float = active_effects.get(effect_type, 1.0)
	active_effects[effect_type] = effect_value * base_value

	match effect_type:
		"breaker_damage":
			pass
		"breaker_radius":
			pass
		"attack_speed":
			pass
		"object_value":
			pass
		_:
			push_warning("Unknown effect type: " + effect_type)

func find_upgrade(upgrade_id: String) -> Dictionary:
	for upgrade in all_upgrades:
		if upgrade.get("id", "") == upgrade_id:
			return upgrade
	return {}

func load_upgrade_data(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_warning("Upgrade data file not found: " + file_path)
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Could not open upgrade file: " + file_path)
		return
	var json_text = file.get_as_text()
	var json = JSON.parse(json_text)
	if json.error != OK:
		push_error("Failed to parse upgrade JSON: " + file_path)
		return
	all_upgrades = json.data
