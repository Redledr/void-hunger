# ============================================================================
# GameWorld.gd - The Game Arena
# ============================================================================
# What this does:
#   Manages the entire round:
#     1. Spawns asteroids that orbit the center
#     2. Handles round timer
#     3. Manages asteroid spawner/respawning
#     4. Emits signals when round ends or objects are destroyed
#
# How to use:
#   1. Add this scene to your Main scene
#   2. Connect the round_started/round_ended signals from Main
#   3. The game handles everything automatically!
#
# Why this exists:
#   - Central controller for the game loop
#   - Separates game logic from UI (HUD handles its own display)
#   - Uses EventBus for cross-scene communication
# ============================================================================

class_name GameWorld
extends Node2D

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
# Accessible nodes from other scripts
@onready var black_hole: BlackHole = $BlackHole
@onready var spawner_timer: Timer = $Spawner/Timer
@onready var asteroids_container: Node2D = $Asteroids
@onready var center_marker: Marker2D = $Spawner/CenterMarker

# =====---------------------------------------------------------------------
# Game Configuration (exported so you can change values in Inspector)
# =====---------------------------------------------------------------------
# Base round duration in seconds
@export var round_duration: float = 30.0
# Number of asteroids to spawn each round
@export var max_asteroids: int = 12
# Mass value each asteroid contributes
@export var mass_per_object: float = 5.0

# =====---------------------------------------------------------------------
# Internal Variables
# =====---------------------------------------------------------------------
# List of currently active asteroids
var active_asteroids: Array[Node2D] = []
# Whether the round is currently active
var is_round_active: bool = false
# Currency earned this round (for HUD display)
var round_currency_this_round: int = 0

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	# Connect signals
	spawner_timer.timeout.connect(_on_timer_timeout)

	# Listen to EventBus signals (we'll emit these in our methods)
	EventBus.round_started.connect(_on_game_round_started)
	EventBus.round_ended.connect(_on_game_round_ended)

# =====---------------------------------------------------------------------
# Called when a round starts (called by Main.gd)
# =====---------------------------------------------------------------------
func start_round() -> void:
	if is_round_active:
		return

	is_round_active = true
	spawner_timer.start(round_duration)

	# Spawn new asteroids
	spawn_asteroids()

# =====---------------------------------------------------------------------
# Called when the round timer times out
# =====---------------------------------------------------------------------
func _on_timer_timeout() -> void:
	if not is_round_active:
		return

	is_round_active = false
	spawner_timer.stop()

	# Clear all asteroids
	for asteroid in active_asteroids:
		asteroid.queue_free()
	active_asteroids.clear()

	# Calculate currency earned this round
	var currency_earned = round_currency_this_round
	round_currency_this_round = 0  # Reset for next round

	# Emit signal that round ended
	EventBus.round_ended.emit(currency_earned)

	# Reset round number
	GameState.round_number += 1

# =====---------------------------------------------------------------------
# Called when round ends via signal
# =====---------------------------------------------------------------------
func _on_game_round_ended(_currency_earned: int) -> void:
	is_round_active = false
	spawner_timer.stop()

	# Clear any remaining asteroids
	for asteroid in active_asteroids:
		asteroid.queue_free()
	active_asteroids.clear()

	print("Round ended!")

# =====---------------------------------------------------------------------
# Spawn and initialize a new asteroid
# =====---------------------------------------------------------------------
func spawn_asteroid() -> Node2D:
	# Create new asteroid instance
	var asteroid = Asteroid.new()
	asteroid.size = Vector2(60, 60)
	asteroid.custom_minimum_size = Vector2(60, 60)
	asteroid.color = Color(0.3, 0.3, 0.35, 1)
	asteroid.health = 30.0
	asteroid.max_health = 30.0
	asteroid.value = 1
	asteroid.orbit_radius = 200
	asteroid.orbit_speed = 0.02 + randf_range(-0.01, 0.01)  # Slight variation
	asteroid.orbit_offset = randf_range(0, 6.28)  # Random starting angle
	asteroid.orbit_center = Vector2(0, 0)

	# Add health bar
	var health_bar = ProgressBar.new()
	health_bar.max_value = 30.0
	health_bar.color = Color(0.4, 0.1, 0.1, 1)
	health_bar.position = Vector2(0, -60)
	health_bar.visible = true
	asteroid.add_child(health_bar)

	# Add particles container
	var particle_container = Node2D.new()
	asteroid.add_child(particle_container)

	# Connect signal
	asteroid.object_destroyed.connect(_on_asteroid_destroyed)

	# Add to container
	asteroids_container.add_child(asteroid)
	asteroid.add_to_group("asteroids")

	# Center initially
	_update_position(asteroid)

	# Store reference
	active_asteroids.append(asteroid)

	return asteroid

# =====---------------------------------------------------------------------
# Spawn multiple asteroids at once
# =====---------------------------------------------------------------------
func spawn_asteroids() -> void:
	for i in range(max_asteroids):
		spawn_asteroid()

# =====---------------------------------------------------------------------
# Center and update all asteroid positions
# =====---------------------------------------------------------------------
func _center_asteroids() -> void:
	for asteroid in active_asteroids:
		_update_position(asteroid)

# =====---------------------------------------------------------------------
# Update asteroid position based on orbit
# =====---------------------------------------------------------------------
func _update_position(asteroid: Node2D) -> void:
	var angle = asteroid.orbit_angle
	var x = asteroid.orbit_center.x + cos(angle + asteroid.orbit_offset) * asteroid.orbit_radius
	var y = asteroid.orbit_center.y + sin(angle + asteroid.orbit_offset) * asteroid.orbit_radius
	asteroid.position = Vector2(x, y)

# =====---------------------------------------------------------------------
# Called when an asteroid is destroyed
# =====---------------------------------------------------------------------
func _on_asteroid_destroyed(value: float, position: Vector2) -> void:
	# Add currency to persistent total
	GameState.add_currency(int(value))

	# Track round earnings (for HUD display)
	round_currency_this_round += int(value)

	# Add mass for black hole growth
	GameState.add_mass(mass_per_object)

	# Emit mass gained signal
	EventBus.mass_gained.emit(mass_per_object)

	# Emit black hole stage change if needed
	if GameState.check_growth():
		EventBus.black_hole_stage_changed.emit(GameState.get_black_hole_stage())

	print("Asteroid destroyed! Gained", value, "currency.")

# =====---------------------------------------------------------------------
# Signal Connections (for future expansion)
# =====---------------------------------------------------------------------
# When you add round timer UI:
# EventBus.round_started.connect(_on_round_timer_start)
# EventBus.round_ended.connect(_on_round_timer_end)
# =====---------------------------------------------------------------------
