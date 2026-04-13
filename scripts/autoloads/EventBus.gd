# ============================================================================
# EventBus.gd - Global Signal Bus
# ============================================================================
# What this does:
#   This is a central hub for all signals in the game. Other scenes don't
#   directly reference each other - instead they listen for signals from
#   EventBus. This keeps scenes independent and makes debugging easier.
#
# How to use:
#   1. In the Godot Editor, create a new Node at "Autoload: EventBus"
#   2. Paste this script into EventBus.gd
#   3. Other scenes connect like: EventBus.object_destroyed.connect(func)
#
# Why this exists:
#   - Prevents "scene A knows about scene B" dependencies
#   - Makes it easy to add logging or debugging to any signal
# ============================================================================

extends Node

# --------------------------------------------------------------------------
# Signal: object_destroyed
# --------------------------------------------------------------------------
# Emitted when an orbiting object is destroyed (broken by the Breaker)
# Other scenes (like GameWorld) connect to this to earn currency.
#
# Example connection in GameWorld.gd:
#   EventBus.object_destroyed.connect(_on_object_destroyed)
#
# Example handler:
#   func _on_object_destroyed(value: int, position: Vector2):
#       GameState.add_currency(value)
#       GameState.add_mass(mass_per_object)
#       print("Object destroyed for", value, "currency!")
#
# Parameters:
#   value: int - Currency value gained when object is destroyed
#   position: Vector2 - World position where the object broke
signal object_destroyed(value: int, position: Vector2)

# --------------------------------------------------------------------------
# Signal: mass_gained
# --------------------------------------------------------------------------
# Emitted when the black hole consumes mass from a destroyed object
# Connect to this if you want to update progress bars or UI
signal mass_gained(amount: float)

# --------------------------------------------------------------------------
# Signal: black_hole_stage_changed
# --------------------------------------------------------------------------
# Emitted when the black hole grows to a new stage
# This happens when cumulative mass reaches certain thresholds
# Connect to trigger animations or effects when the black hole grows
signal black_hole_stage_changed(new_stage: int)

# --------------------------------------------------------------------------
# Signal: round_started
# --------------------------------------------------------------------------
# Emitted at the beginning of each round
# Connect to this to reset timers, spawn objects, or show round UI
signal round_started()

# --------------------------------------------------------------------------
# Signal: round_ended
# --------------------------------------------------------------------------
# Emitted when the round timer expires
# Contains the total currency earned during this round
signal round_ended(currency_earned: int)

# --------------------------------------------------------------------------
# Signal: upgrade_purchased
# --------------------------------------------------------------------------
# Emitted when a player buys an upgrade in the UpgradeShop
# Connect to this to deduct currency from GameState and apply effects
signal upgrade_purchased(upgrade_id: String)

# --------------------------------------------------------------------------
# Signal: currency_changed
# --------------------------------------------------------------------------
# Emitted whenever currency increases or decreases
# Used to update the HUD currency display in real-time
signal currency_changed(new_total: int)
