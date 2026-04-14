# ============================================================================
# Asteroid.gd - Orbiting Asteroid
# ============================================================================
# What this does:
#   1. Orbits around the center point using sine/cosine motion
#   2. Gets damaged when Breaker overlaps it
#   3. Emits object_destroyed signal when health reaches 0
#   4. Plays particles and breaks on destruction
#
# How to use:
#   1. GameWorld spawns this scene
#   2. GameWorld sets initial position and orbit parameters
#   3. Asteroid handles its own orbit and damage automatically
#   4. Connect to object_destroyed signal in GameWorld
#
# Why this exists:
#   - Encapsulates asteroid behavior in one place
#   - Uses code-driven orbit (cos/sin) instead of AnimationPlayer
#   - Keeps physics separate from rendering (CharacterBody2D vs Node2D)
#   - Emission signals follow architecture rules (no direct references)
# ============================================================================

class_name Asteroid
extends ColorRect

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
@onready var health_bar: ProgressBar = $HealthBar

# =====---------------------------------------------------------------------
# Exported Variables (set in Inspector or by GameWorld)
# =====---------------------------------------------------------------------
# Asteroid's health points
@export var health: float = 30.0
# Maximum health (for health bar)
@export var max_health: float = 30.0
# Currency value when destroyed
@export var value: int = 1
# Current angle for orbit (radians)
@export var orbit_angle: float = 0.0
# Orbital radius (distance from center)
@export var orbit_radius: float = 200.0
# Speed of orbit (radians per second)
@export var orbit_speed: float = 0.05
# Time offset for this asteroid (so they don't all orbit together)
@export var orbit_offset: float = 0.0
# Center position (set by GameWorld)
@export var orbit_center: Vector2 = Vector2(0, 0)

# =====---------------------------------------------------------------------
# Internal Variables
# =====---------------------------------------------------------------------
# Last time this process ran (for time-based movement)
var last_process_time: float = 0.0
# Center position for orbit
var _orbit_center: Vector2

# =====---------------------------------------------------------------------
# Signals (emit from this script)
# =====---------------------------------------------------------------------
# When this asteroid is destroyed, emit this signal
# Connect in GameWorld.gd: EventBus.object_destroyed.connect(_handler)
signal object_destroyed(value: float, position: Vector2)

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	# Set center for orbit
	_orbit_center = orbit_center

	# Center the asteroid initially
	_update_position()

# =====---------------------------------------------------------------------
# Process Method - runs every frame
# =====---------------------------------------------------------------------
func _process(delta: float) -> void:
	# Only process when round is active
	if not GameState.get_black_hole_stage() > 0:
		return

	# Update orbit position
	orbit_angle += orbit_speed * delta
	_update_position()

	# Update health bar
	var health_ratio = health / max_health
	health_bar.progress_ratio = health_ratio

# =====---------------------------------------------------------------------
# Update asteroid position based on orbit angle
# =====---------------------------------------------------------------------
func _update_position() -> void:
	# Calculate position using circular motion (cos/sin)
	var x = orbit_center.x + cos(orbit_angle + orbit_offset) * orbit_radius
	var y = orbit_center.y + sin(orbit_angle + orbit_offset) * orbit_radius

	# Set position
	position = Vector2(x, y)

# =====---------------------------------------------------------------------
# Public method: Apply damage to this asteroid
# =====---------------------------------------------------------------------
func take_damage(amount: int) -> void:
	health -= amount

	# If health dropped below 0, destroy immediately
	if health <= 0:
		_destroy_object()
	else:
		# Visual feedback - flash the asteroid
		color.a = 0.5
		await get_tree().create_timer(0.1).timeout
		color.a = 1.0

# =====---------------------------------------------------------------------
# Called when Breaker overlaps this asteroid (alias for take_damage)
# =====---------------------------------------------------------------------
func _on_damage_applied(amount: int) -> void:
	take_damage(amount)

# =====---------------------------------------------------------------------
# Called when the asteroid is destroyed
# =====---------------------------------------------------------------------
func _destroy_object() -> void:
	# Emit signal BEFORE queue_free so other scripts can receive it
	object_destroyed.emit(value, global_position)

	# Now remove from scene
	queue_free()

# =====---------------------------------------------------------------------
# Signal Handler: When called by EventBus, don't handle here.
# The asteroid already freed itself in _destroy_object.
# =====---------------------------------------------------------------------

# =====---------------------------------------------------------------------
# Signal Connections
# =====---------------------------------------------------------------------
# Connect to the global object_destroyed signal (for cleanup)
# func connect_signal_object_destroyed(value: int, position: Vector2) -> void:
# 	EventBus.object_destroyed.connect(_on_object_destroyed)
# =====---------------------------------------------------------------------
