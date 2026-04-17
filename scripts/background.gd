# background.gd
# Attach to main scene to provide floating particles background
extends CanvasLayer

func _ready():
	var particles = CPUParticles2D.new()
	particles.amount = 300
	particles.lifetime = 10.0
	particles.preprocess = 5.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(1920, 1080)  # Cover screen
	particles.direction = Vector2(0, -10)  # Slight upward drift
	particles.spread = 30.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 15.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1.0, 1.0, 1.0, 0.3)  # White, semi-transparent
	add_child(particles)
