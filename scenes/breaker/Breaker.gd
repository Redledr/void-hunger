# ============================================================================
# Breaker.gd - The Damage Zone (Cursor)
# ============================================================================
# What this does:
#   1. Follows the mouse cursor
#   2. Fires damage ticks on a timer (not frame-rate dependent)
#   3. Applies damage to objects in its Area2D collision
#   4. Deactivates when round ends
#
# How to use:
#   1. Add this scene to your GameWorld scene
#   2. Enable the Breaker when round starts
#   3. Disable when round ends
#
# Why this exists:
#   - Timer-based damage (0.5s interval) is frame-rate independent
#   - Area2D handles hit detection automatically
#   - Cursor follows mouse input
# ============================================================================

class_name Breaker
extends Area2D

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
@onready var timer: Timer = $Timer
@onready var cursor_marker: Marker2D = $CursorMarker

# =====---------------------------------------------------------------------
# Exported Variables (set in Inspector or by GameWorld)
# =====---------------------------------------------------------------------
# Damage dealt per tick
@export var damage: int = 10
# Collision radius (size of damage zone)
@export var radius: float = 40.0

# =====---------------------------------------------------------------------
# Internal Variables
# =====---------------------------------------------------------------------
# Whether the breaker is currently active
var is_active: bool = false
# Mouse position
var _mouse_position: Vector2

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	# Connect to input for cursor following
	Input.mouse_relative_mode = Input.MOUSE_RELATIVE_MODE.OFF
	Input.mouse_mode = Input.MOUSE_MODE.VISIBLE
	Input.mouse_default_cursor_shape = Input.CURSOR_TYPE.CROSSHAIR

# =====---------------------------------------------------------------------
# Activate the breaker (called by GameWorld)
# =====---------------------------------------------------------------------
func activate() -> void:
	is_active = true
	# Update radius in case it changed
	custom_minimum_size.x = radius * 2
	custom_minimum_size.y = radius * 2
	timer.start()

# =====---------------------------------------------------------------------
# Deactivate the breaker (called when round ends)
# =====---------------------------------------------------------------------
func deactivate() -> void:
	is_active = false
	timer.stop()
	# Shrink visual (optional)
	custom_minimum_size.x = 0
	custom_minimum_size.y = 0

# =====---------------------------------------------------------------------
# Called every frame when active
# =====---------------------------------------------------------------------
func _process(_delta: float) -> void:
	if not is_active:
		return

	# Follow cursor
	_mouse_position = Input.get_mouse_position()
	position = _mouse_position

	# Show debug marker
	cursor_marker.visible = false

# =====---------------------------------------------------------------------
# Called when timer ticks (every 0.5 seconds by default)
# =====---------------------------------------------------------------------
func _on_timer_timeout() -> void:
	if not is_active:
		return

	# Apply damage to all overlapping objects
	_apply_damage()

# =====---------------------------------------------------------------------
# Apply damage to overlapping objects
# =====---------------------------------------------------------------------
func _apply_damage() -> void:
	# get_overlapping_bodies() gets physics bodies, but our asteroids are Node2D
	# Use get_overlapping_layers() to get overlapping nodes
	var overlapping_nodes = get_overlapping_layers()

	for node in overlapping_nodes:
		# Check if it's our Asteroid type
		if node is Asteroid:
			# Apply damage
			node.take_damage(damage)

# =====---------------------------------------------------------------------
# Public: Apply damage manually (for testing or upgrades)
# =====---------------------------------------------------------------------
func take_damage(amount: int) -> void:
	for child in get_children():
		if child is Asteroid:
			child._on_damage_applied(amount)

# =====---------------------------------------------------------------------
# Signal Connections
# =====---------------------------------------------------------------------
# timer.timeout.connect(_on_timer_timeout)
# =====---------------------------------------------------------------------
