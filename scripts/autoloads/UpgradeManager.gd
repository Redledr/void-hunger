# ============================================================================
# UpgradeManager.gd - Upgrade Tree System
# ============================================================================
# What this does:
#   Manages all upgrades: their data, costs, prerequisites, and effects.
#   When you buy an upgrade, this script handles:
#     1. Checking you have enough currency
#     2. Checking prerequisites are met
#     3. Applying the effect to the game
#
# How to use:
#   # Check if upgrade is available:
#   if UpgradeManager.is_upgrade_available("breaker_damage"):
#       UpgradeManager.buy_upgrade("breaker_damage")
#
#   # Check if player has purchased an upgrade:
#   var has_damage_upgrade = UpgradeManager.has_purchased("breaker_damage")
#
# Why this exists:
#   - Separates upgrade logic from UI (so UI doesn't know about game mechanics)
#   - All upgrade data comes from data/upgrades.json file
# ============================================================================

extends NodeName

# The node name must be "UpgradeManager" to work as an Autoload
name = "UpgradeManager"

# =====---------------------------------------------------------------------
# Upgrade Data Structure
# =====---------------------------------------------------------------------
# Each upgrade has:
#   - id: Unique identifier like "breaker_damage"
#   - label: Display name like "+ Damage"
#   - description: Tooltip text
#   - cost: Currency required to purchase
#   - effect_type: What kind of effect (damage, radius, speed, etc.)
#   - effect_value: How much the effect changes
#   - prereq_ids: Other upgrades needed before buying this one
# =====---------------------------------------------------------------------

# List of all upgrades loaded from data/upgrades.json
var all_upgrades: Array[Dictionary] = []

# Set of upgrade IDs that have been purchased
var purchased_upgrades: Set[String] = {}

# Dictionary mapping effect_type to their current game effects
# Example: { "breaker_damage": 1.0, "breaker_radius": 40 }
var active_effects: Dictionary = {}

# =====---------------------------------------------------------------------
# Methods (functions you call from other scenes)
# =====---------------------------------------------------------------------

# Initialize the upgrade system (call once at game start)
func _ready() -> void:
	# Load upgrade data from file if it exists
	# For Phase 1, we'll use hardcoded data (no JSON needed yet)
	# You can replace this with JSON loading later
	# Example: load_upgrade_data("res://data/upgrades.json")
	# Initialize with some default effects
	active_effects["breaker_damage"] = 1.0  # 100% damage
	active_effects["breaker_radius"] = 40   # 40px radius
	active_effects["attack_speed"] = 0.5    # 0.5s interval
	active_effects["object_value"] = 1.0    # 100% value
	print("UpgradeManager initialized")

# Check if an upgrade is available to purchase
# Returns false if:
#   - Not enough currency
#   - Prerequisites not met
#   - Already purchased
func is_upgrade_available(upgrade_id: String) -> bool:
	var upgrade = find_upgrade(upgrade_id)
	if not upgrade:
		return false

	# Check currency
	if GameState.get_currency() < upgrade.cost:
		return false

	# Check prerequisites
	for prereq_id in upgrade.prereq_ids:
		if not purchased_upgrades.has(prereq_id):
			return false

	# All checks passed - upgrade is available
	return true

# Check if an upgrade has been purchased
func has_purchased(upgrade_id: String) -> bool:
	return purchased_upgrades.has(upgrade_id)

# Buy an upgrade (called by UpgradeShop scene)
func buy_upgrade(upgrade_id: String) -> bool:
	var upgrade = find_upgrade(upgrade_id)
	if not upgrade:
		push_error("Tried to buy non-existent upgrade: " + upgrade_id)
		return false

	# Check if already purchased
	if purchased_upgrades.has(upgrade_id):
		push_warning("Already purchased: " + upgrade_id)
		return false

	# Check prerequisites first
	for prereq_id in upgrade.prereq_ids:
		if not purchased_upgrades.has(prereq_id):
			push_error("Missing prerequisite: " + prereq_id)
			return false

	# Deduct currency
	GameState.add_currency(-upgrade.cost)

	# Mark as purchased
	purchased_upgrades.add(upgrade_id)

	# Apply the effect (handle based on effect_type)
	apply_effect(upgrade)

	# Emit signal for UI to update
	EventBus.upgrade_purchased.emit(upgrade_id)

	print("Purchased: " + upgrade.label + " (" + upgrade.id + ")")
	return true

# Apply an upgrade's effect to the game
func apply_effect(upgrade: Dictionary) -> void:
	var effect_type = upgrade.effect_type
	var effect_value = upgrade.effect_value

	# Base effect value (multiply by any existing effects of same type)
	var base_value = active_effects.get(effect_type, 1.0)
	effect_value *= base_value

	# Apply to active_effects dictionary
	active_effects[effect_type] = effect_value

	# Apply to actual game objects based on effect type
	match effect_type:
		"breaker_damage":
			# Multiply Breaker's damage by this factor
			# You'll need to connect to Breaker node later
			pass
		"breaker_radius":
			# Update Breaker collision radius
			# Breaker.new_radius = effect_value
			pass
		"attack_speed":
			# Update Breaker timer interval
			# Breaker.timer_wait = effect_value
			pass
		"object_value":
			# Multiply currency gained from objects
			pass
		# Add more effect types as you implement them
		_:
			push_warning("Unknown effect type: " + effect_type)

# Find an upgrade by ID
func find_upgrade(upgrade_id: String) -> Dictionary:
	for upgrade in all_upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null

# Load upgrade data from JSON file (for future use)
# You don't need this for Phase 1, but it's here for reference
func load_upgrade_data(file_path: String) -> void:
	var file = File.new()
	if file.file_exists(file_path):
		var error = file.open(file_path, File.READ)
		if error == Error.OK:
			var json_text = file.get_as_text()
			file.close()
			# Parse JSON here (requires proper JSON structure)
			# all_upgrades = json_text
		else:
			push_error("Error reading upgrade file: " + str(error))
	else:
		push_warning("Upgrade data file not found: " + file_path)
	file.rmdir()
