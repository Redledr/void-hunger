class_name GameConfigClass
extends Node

# ── Spawning ──────────────────────────────────────────────────────────────────
@export_group("Spawning")
## Seconds between object spawns at game start.
@export var spawn_interval_base:      float = 2.0
## Shortest allowed spawn interval regardless of upgrades.
@export var spawn_interval_min:       float = 0.3
## Hard cap on simultaneous orbiting objects.
@export var max_objects:              int   = 40

# ── Passive Pull ──────────────────────────────────────────────────────────────
@export_group("Passive Pull")
## Orbit radius reduction per second applied to all objects passively.
@export var passive_pull_base:        float = 0.3
## Additional pull per unit of black hole mass (scales pull with size).
@export var passive_pull_scale:       float = 5

# ── Orbit ─────────────────────────────────────────────────────────────────────
@export_group("Orbit")
## Closest orbit radius an object will settle into after spawning.
@export var orbit_radius_min:         float = 150.0
## Farthest orbit radius an object will settle into after spawning.
@export var orbit_radius_max:         float = 280.0
## Minimum angular orbit speed in radians per second.
@export var orbit_speed_min:          float = 0.3
## Maximum angular orbit speed in radians per second.
@export var orbit_speed_max:          float = 0.7
## Chance (0–1) that an object orbits counter-clockwise.
@export var orbit_reverse_chance:     float = 0.5

# ── Object Spawn Range ────────────────────────────────────────────────────────
@export_group("Object Spawn Range")
## Lower bound multiplier on black hole mass for eligible spawn types.
@export var spawn_mass_lower_mult:    float = 0.2
## Minimum lower bound regardless of mass (avoids empty early spawns).
@export var spawn_mass_lower_floor:   float = 0.05
## Upper bound multiplier on black hole mass for eligible spawn types.
@export var spawn_mass_upper_mult:    float = 5.0
## Minimum upper bound regardless of mass (ensures something always spawns).
@export var spawn_mass_upper_floor:   float = 2.0
## Per-tier bonus added to the upper bound multiplier when tier is unlocked.
@export var spawn_tier_bonus_scalar:  float = 2.0

# ── Nudge ─────────────────────────────────────────────────────────────────────
@export_group("Nudge")
## Click radius in pixels; objects within this range receive a nudge.
@export var nudge_radius:             float = 80.0
## Passed to apply_nudge(); reserved for future strength scaling.
@export var nudge_strength:           float = 120.0
## Extra lerp speed added when an object begins spiraling.
@export var nudge_lerp_boost:         float = 5.0
## Default lerp speed for orbit radius interpolation.
@export var base_lerp_speed:          float = 2.5
## Rate at which nudge lerp boost decays back to base speed.
@export var nudge_lerp_decay:         float = 4.0

# ── Spiral ────────────────────────────────────────────────────────────────────
@export_group("Spiral")
## Orbit radius reduction per second while an object is spiraling inward.
@export var spiral_rate_default:      float = 60.0

# ── Energy ────────────────────────────────────────────────────────────────────
@export_group("Energy")
## Energy awarded per unit of mass on absorption (before skill multipliers).
@export var energy_per_mass_unit:     float = 0.1

# ── Black Hole ────────────────────────────────────────────────────────────────
@export_group("Black Hole")
## Visual/collision radius at zero mass.
@export var black_hole_base_size:     float = 40.0
## Radius growth per log-unit of mass.
@export var black_hole_mass_scale:    float = 4.0
## Accretion disk rotation speed in radians per second.
@export var rotation_speed:           float = 0.18
## Vertical squash of the disk ellipse (1.0 = circle, 0.0 = flat line).
@export var disk_tilt:                float = 0.55
## Inner disk band radius as a multiple of the black hole radius.
@export var disk_inner_scale:         float = 1.2
## Outer disk band radius as a multiple of the black hole radius.
@export var disk_outer_scale:         float = 2.8
## Number of glow rings drawn behind the black hole.
@export var glow_layers:              int   = 6
## Glow radius at the innermost ring as a multiple of black hole radius.
@export var glow_radius_mult:         float = 2.8
## Peak alpha of the innermost glow ring.
@export var glow_alpha_peak:          float = 0.06
## Number of bands in the accretion disk.
@export var disk_bands:               int   = 8
## Line width for accretion disk rendering.
@export var disk_line_width:          float = 1.8
## Segment count for arc/ellipse drawing (higher = smoother, costs perf).
@export var arc_segments:             int   = 64

# ── Trail ─────────────────────────────────────────────────────────────────────
@export_group("Trail")
## Number of positions stored in each object's trail buffer.
@export var trail_length_default:     int   = 20
## Alpha multiplier applied to trail line segments.
@export var trail_alpha:              float = 0.5
## Pixel width of trail lines.
@export var trail_line_width:         float = 2.0
## Glow polygon radius as a multiple of the object's size.
@export var object_glow_scale:        float = 1.25

# ── Particles ─────────────────────────────────────────────────────────────────
@export_group("Particles")
## Total pooled emitters. Increase if bursts get skipped during heavy action.
@export var particle_pool_size:       int   = 20
## Particles fired per absorption burst.
@export var particle_burst_amount:    int   = 18
## How long burst particles live in seconds.
@export var particle_burst_lifetime:  float = 0.6
## Minimum burst particle speed.
@export var particle_speed_min:       float = 40.0
## Maximum burst particle speed.
@export var particle_speed_max:       float = 140.0

# ── Debug ─────────────────────────────────────────────────────────────────────
@export_group("Debug")
## Mass target used to calculate the mid-game ETA in the debug overlay.
@export var debug_eta_target_mass:    float = 500.0
## How often (seconds) absorb rate and mass-per-absorb are recalculated.
@export var debug_sample_window:      float = 1.0

# ── Currency ──────────────────────────────────────────────────────────────────
@export_group("Currency")
## Starting energy injected for testing the skill tree without grinding.
@export var test_energy:              float = 500.0
@export var test_mass:                float = 500.0
