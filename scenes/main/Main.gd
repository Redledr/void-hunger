# ============================================================================
# Main.gd - Main Scene Controller
# ============================================================================
# What this does:
#   1. Starts rounds and activates the game world
#   2. Follows EventBus signals to know when rounds end
#   3. Transitions to UpgradeShop when round ends
#
# How to use:
#   1. This scene is automatically loaded as the root
#   2. No external connections needed - listens to EventBus
#   3. Game handles itself automatically!
#
# Why this exists:
#   - Single point of control for scene transitions
#   - Doesn't use get_node() to access other scenes
#   - Follows architecture rules (uses signals, not direct references)
# ============================================================================

class_name Main
extends Node2D

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
@onready var game_world: Node2D = $GameWorld
@onready var breaker: Area2D = $Breaker

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	print("Main scene ready! Starting first round. ..")

	# Start the first round
	game_world.start_round()

# =====---------------------------------------------------------------------
# Called when round ends (via EventBus signal)
# =====---------------------------------------------------------------------
func _on_round_ended(_currency_earned: int) -> void:
	# Deactivate breaker
	breaker.visible = false
	breaker.deactivate()

	# Show upgrade shop when round ends
	get_tree().change_scene_to_file("res://scenes/ui/UpgradeShop.tscn")

# =====---------------------------------------------------------------------
# Called when upgrade is purchased (for currency deduction)
# =====---------------------------------------------------------------------
func _on_upgrade_purchased(_upgrade_id: String) -> void:
	# For Phase 1, no upgrades yet
	# In Phase 4, you'd handle currency deduction here
	pass

# =====---------------------------------------------------------------------
# Signal Connections
# =====---------------------------------------------------------------------
# Connect to EventBus signals
EventBus.round_started.connect(_on_round_started)
EventBus.round_ended.connect(_on_round_ended)
EventBus.upgrade_purchased.connect(_on_upgrade_purchased)

# =====---------------------------------------------------------------------
# (No utility functions needed for Phase 1)
# =====---------------------------------------------------------------------
