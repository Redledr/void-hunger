@tool
class_name GameConfigClass
extends Node

# ── Static self-reference so any script can do GameConfig.nudge_radius ──────
static var instance: Node

func _enter_tree() -> void:
	instance = self

# ── Spawning ──────────────────────────────────────────────────────────────────
@export_group("Spawning")
@export var spawn_interval_base:   float = 2.0
@export var spawn_interval_min:    float = 0.3
@export var max_objects:           int   = 40

# ── Passive Pull ──────────────────────────────────────────────────────────────
@export_group("Passive Pull")
@export var passive_pull_base:     float = 0.3
@export var passive_pull_scale:    float = 0.0
@export var orbit_radius_min:      float = 150.0
@export var orbit_radius_max:      float = 280.0

# ── Nudge ─────────────────────────────────────────────────────────────────────
@export_group("Nudge")
@export var nudge_radius:          float = 80.0
@export var nudge_strength:        float = 120.0
@export var nudge_lerp_boost:      float = 5.0
@export var base_lerp_speed:       float = 2.5

# ── Spiral ────────────────────────────────────────────────────────────────────
@export_group("Spiral")
@export var spiral_rate_default:   float = 60.0

# ── Energy ────────────────────────────────────────────────────────────────────
@export_group("Energy")
@export var energy_per_mass_unit:  float = 0.1

# ── Black Hole ────────────────────────────────────────────────────────────────
@export_group("Black Hole")
@export var black_hole_base_size:  float = 40.0
@export var black_hole_mass_scale: float = 4.0
@export var rotation_speed:        float = 0.18  # add this
@export var disk_tilt:        float = 0.55   # was 0.35 — more visible angle
@export var disk_inner_scale: float = 1.2    # was 1.3
@export var disk_outer_scale: float = 2.8    # was 2.2 — wider spread

# ── Trail ─────────────────────────────────────────────────────────────────────
@export_group("Trail")
@export var trail_length_default:  int   = 20
