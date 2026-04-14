# ============================================================================
# BreakParticles.gd - Break Effect
# ============================================================================
# What this does:
#   Spawns a particle explosion when an asteroid breaks
#   Uses GPUParticles2D for performance (up to 4k particles)
#
# How to use:
#   1. Breaker scene calls this when asteroid is destroyed
#   2. Particles automatically play and fade out
#   3. Clean up happens automatically
#
# Why this exists:
#   - Visual feedback for asteroid destruction
#   - Makes the game feel more satisfying
#   - GPUParticles2D handles many particles efficiently
# ============================================================================

class_name BreakParticles
extends GPUParticles2D

# =====---------------------------------------------------------------------
# Node References
# =====---------------------------------------------------------------------
@onready var fallback_rect: ColorRect = $FallbackRect

# =====---------------------------------------------------------------------
# Methods
# =====---------------------------------------------------------------------

# Called when the scene is ready
func _ready() -> void:
	if RenderingServer.get_rendering_device() == null:
		visible = false
		fallback_rect.visible = true

# =====---------------------------------------------------------------------
# Set particle color (can be called from outside)
# =====---------------------------------------------------------------------
func set_particle_color(color: Color) -> void:
	# For GPUParticles2D, color is set in the inspector
	# For fallback, set directly
	if fallback_rect.visible:
		fallback_rect.color = color
	else:
		# Set GPUParticles2D color (requires texture, but we don't have one)
		pass
