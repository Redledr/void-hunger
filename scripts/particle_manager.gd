# particle_manager.gd
# Attach to a Node2D named ParticleManager, child of the main scene.
#
# Owns a pool of CPUParticles2D emitters so space_object never manages
# its own particles. Call burst() from anywhere — it grabs a free emitter,
# positions it, fires once, then returns it to the pool automatically.
#
# Add to main scene as:
#   ParticleManager (Node2D, this script)
extends Node2D

const POOL_SIZE:      int   = 20
const BURST_AMOUNT:   int   = 18
const BURST_LIFETIME: float = 0.6
const BURST_SPEED_MIN:float = 40.0
const BURST_SPEED_MAX:float = 140.0

var _pool: Array[CPUParticles2D] = []

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p := CPUParticles2D.new()
		p.emitting        = false
		p.one_shot        = true
		p.explosiveness   = 0.95   # fire all particles at once
		p.amount          = BURST_AMOUNT
		p.lifetime        = BURST_LIFETIME
		p.emission_shape  = CPUParticles2D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 4.0
		p.direction       = Vector2(0, 0)
		p.spread          = 180.0
		p.gravity         = Vector2(0, 0)
		p.initial_velocity_min = BURST_SPEED_MIN
		p.initial_velocity_max = BURST_SPEED_MAX
		p.scale_amount_min     = 1.5
		p.scale_amount_max     = 3.5
		p.damping_min          = 60.0
		p.damping_max          = 120.0
		add_child(p)
		_pool.append(p)

# Fire a burst at world position `pos` using `color`.
# Safe to call every frame — silently skips if pool is exhausted.
func burst(pos: Vector2, color: Color, size: float = 10.0) -> void:
	var emitter := _get_free()
	if emitter == null:
		return
	emitter.position               = pos
	emitter.color                  = Color(color.r, color.g, color.b, 1.0)
	emitter.emission_sphere_radius = size * 0.5
	emitter.amount                 = clampi(int(size * 1.5), 6, 40)
	emitter.scale_amount_min       = size * 0.08
	emitter.scale_amount_max       = size * 0.18
	emitter.emitting               = true
	await get_tree().create_timer(BURST_LIFETIME + 0.1).timeout
	emitter.emitting = false

func _get_free() -> CPUParticles2D:
	for p in _pool:
		if not p.emitting:
			return p
	return null  # pool exhausted — caller skips gracefully
