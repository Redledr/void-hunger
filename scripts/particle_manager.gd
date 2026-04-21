extends Node2D

var _pool: Array[CPUParticles2D] = []

func _ready() -> void:
	for i in range(GameConfig.particle_pool_size):
		var p := CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = GameConfig.particle_burst_amount
		p.lifetime = GameConfig.particle_burst_lifetime
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 4.0
		p.direction = Vector2(0, 0)
		p.spread = 180.0
		p.gravity = Vector2(0, 0)
		p.initial_velocity_min = GameConfig.particle_speed_min
		p.initial_velocity_max = GameConfig.particle_speed_max
		p.scale_amount_min = 1.5
		p.scale_amount_max = 3.5
		p.damping_min = 60.0
		p.damping_max = 120.0
		add_child(p)
		_pool.append(p)

func burst(pos: Vector2, color: Color, size: float = 10.0) -> void:
	var emitter := _get_free()
	if emitter == null:
		return
	emitter.position = pos
	emitter.color = Color(color.r, color.g, color.b, 1.0)
	emitter.emission_sphere_radius = size * 0.5
	emitter.amount = clampi(int(size * 1.5), 6, 40)
	emitter.scale_amount_min = size * 0.08
	emitter.scale_amount_max = size * 0.18
	emitter.emitting = true
	await get_tree().create_timer(GameConfig.particle_burst_lifetime + 0.1).timeout
	emitter.emitting = false

func _get_free() -> CPUParticles2D:
	for p in _pool:
		if not p.emitting:
			return p
	return null