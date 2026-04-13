# CLAUDE.md — Black Hole Incremental (Godot 4)

> Working title: **Void Hunger**
> Reference game: *A Game About Feeding A Black Hole* (Aarimous Studios, 2025)
> Goal: Near-exact mechanic clone for learning purposes. Desktop only. No multiplayer.

---

## Project Overview

A minimalist incremental game where the player hovers their cursor over orbiting celestial objects to break them apart. Broken matter feeds a central black hole, growing its mass in stages. Between timed rounds, the player spends earned currency on a persistent upgrade tree. No lose state. Pure optimization loop.

---

## Engine & Stack

- **Engine:** Godot 4.x (latest stable)
- **Language:** GDScript only — no C#
- **Renderer:** Compatibility (2D only, no 3D nodes)
- **Platform target:** Desktop (Windows primary, Linux secondary)
- **Export:** Standard Godot export templates — no web export needed
- **Version control:** Git. Commit after each completed feature, not mid-feature.

---

## Project Structure

```
res://
├── CLAUDE.md                  # This file — always read before making changes
├── project.godot
├── scenes/
│   ├── main/
│   │   ├── Main.tscn          # Root scene — loads GameWorld or UpgradeShop
│   │   └── Main.gd
│   ├── game_world/
│   │   ├── GameWorld.tscn     # The play arena — black hole + orbiting objects
│   │   └── GameWorld.gd
│   ├── black_hole/
│   │   ├── BlackHole.tscn     # Central black hole visual + growth stages
│   │   └── BlackHole.gd
│   ├── objects/
│   │   ├── BaseObject.tscn    # Abstract parent: health, value, orbit behavior
│   │   ├── BaseObject.gd
│   │   ├── Asteroid.tscn
│   │   ├── Planet.tscn
│   │   └── Star.tscn
│   ├── breaker/
│   │   ├── Breaker.tscn       # The cursor/damage zone
│   │   └── Breaker.gd
│   ├── ui/
│   │   ├── HUD.tscn           # In-round: timer bar, mass progress, currency
│   │   ├── HUD.gd
│   │   ├── UpgradeShop.tscn   # Between-round upgrade tree UI
│   │   └── UpgradeShop.gd
│   └── effects/
│       ├── BreakParticles.tscn
│       └── ElectricChain.tscn
├── scripts/
│   ├── autoloads/
│   │   ├── GameState.gd       # Autoload: persistent run data, upgrade flags
│   │   ├── UpgradeManager.gd  # Autoload: upgrade tree data + purchase logic
│   │   └── EventBus.gd        # Autoload: global signal bus
│   └── resources/
│       ├── UpgradeData.gd     # Resource class defining one upgrade node
│       └── ObjectData.gd      # Resource class defining one object type
├── assets/
│   ├── sprites/
│   ├── fonts/
│   └── audio/
└── data/
    ├── upgrades.json          # All upgrade definitions (id, cost, effect, prereqs)
    └── object_types.json      # All object type definitions (hp, value, special)
```

---

## Architecture Rules

These are non-negotiable. Do not deviate without a comment explaining why.

1. **No direct node references across scene boundaries.** Use `EventBus` signals for cross-scene communication. Scenes do not `get_node()` into each other.

2. **All persistent game data lives in `GameState.gd` (autoload).** Nothing else writes to disk or holds run state. If you need data in a scene, read it from GameState.

3. **All upgrade logic lives in `UpgradeManager.gd` (autoload).** Scenes never modify upgrade state directly. They call UpgradeManager methods and read results.

4. **Objects do not know about the black hole.** When an object is fully destroyed, it emits `object_destroyed(value, position)` on EventBus. GameWorld listens and handles mass gain.

5. **No hardcoded numbers in scene scripts.** All tunable values (damage, costs, timers) come from exported variables or data resources. Makes balancing possible without hunting through code.

6. **Breaker damage is timer-based, not input-based.** The Breaker fires on an internal `Timer` tick, not on mouse press. This matches the reference game's auto-attack behavior.

---

## Core Systems

### 1. Round Loop

```
Round Start
  → GameWorld initializes object spawner
  → RoundTimer starts (base: 30s, modified by upgrades)
  → Breaker activates (follows cursor, auto-attacks on tick)

During Round
  → Objects orbit black hole center
  → Breaker overlaps object → damage tick applied
  → Object HP reaches 0 → breaks → emits object_destroyed signal
  → GameWorld receives signal → adds currency + mass to GameState
  → BlackHole checks mass thresholds → grows stage if threshold met
  → HUD updates timer bar, mass progress bar, currency counter

Round End (timer expires)
  → Breaker deactivates
  → GameWorld pauses object spawner
  → EventBus emits round_ended(currency_earned)
  → Main transitions to UpgradeShop scene
```

### 2. Black Hole Growth

- 10 growth stages (Stage 1–10)
- Each stage has a mass threshold (e.g., 100, 300, 700, 1500...)
- Visual size scales with stage (use `tween` on scale, not instant)
- Stage milestone bonuses defined in `upgrades.json`
- Mass resets each round; stage progress is persistent across rounds

### 3. Object Types

Defined in `data/object_types.json`. Minimum viable set:

| Type       | HP    | Base Value | Special Behavior         |
|------------|-------|------------|--------------------------|
| Asteroid   | Low   | 1          | None                     |
| Dense Rock | Med   | 3          | None                     |
| Planet     | High  | 10         | None                     |
| Star       | V.High| 25         | None                     |
| Electric   | Med   | 5          | On death: chain to nearby objects |
| Radioactive| Med   | 5          | On death: leaves damage cloud AoE |

Add types only after base types are working. Do not build specials first.

### 4. Upgrade Tree

- Defined entirely in `data/upgrades.json`
- Each node has: `id`, `label`, `description`, `cost`, `effect_type`, `effect_value`, `prereq_ids[]`
- UpgradeManager loads this file at startup and builds the tree graph
- Purchased upgrades stored as a `Set<String>` of IDs in GameState
- UI reads from UpgradeManager to render nodes; does not touch raw JSON

**Effect types to implement (in priority order):**
1. `breaker_damage` — multiplier on damage per tick
2. `breaker_radius` — increases Breaker Area2D collision size
3. `attack_speed` — reduces Breaker timer interval
4. `object_value` — multiplier on currency per object
5. `round_time` — adds seconds to base round timer
6. `spawn_count` — increases max objects alive at once
7. `electric_chain` — enables/enhances electric asteroid chain behavior
8. `radioactive_aoe` — enables/enhances radioactive cloud behavior

### 5. Currency & Progression

- Currency earned per round is added to a persistent total in GameState
- Upgrades deduct from persistent total — currency does NOT reset between rounds
- Currency display in HUD updates in real time via EventBus signal

---

## EventBus Signals

All global signals live here. Document every signal added.

```gdscript
# EventBus.gd
signal object_destroyed(value: int, position: Vector2)
signal mass_gained(amount: float)
signal black_hole_stage_changed(new_stage: int)
signal round_started()
signal round_ended(currency_earned: int)
signal upgrade_purchased(upgrade_id: String)
signal currency_changed(new_total: int)
```

---

## Scene Transition Pattern

Main.gd owns all scene transitions. No other script calls `get_tree().change_scene_to_file()`.

```gdscript
# Main.gd handles:
# GameWorld → UpgradeShop (on round_ended signal)
# UpgradeShop → GameWorld (on player confirms "Next Round")
```

---

## Implementation Order

Build in this order. Do not skip ahead. Each phase should be playable/testable before moving on.

### Phase 1 — Minimal Playable Loop
- [ ] Project setup, autoloads, EventBus with placeholder signals
- [ ] GameWorld scene with static black hole placeholder
- [ ] Single asteroid type that orbits the center (circular path via code)
- [ ] Breaker that follows cursor and damages overlapping objects on timer tick
- [ ] Object destruction: plays particle, emits signal, removes from scene
- [ ] HUD: currency counter only
- [ ] Round timer (hardcoded 30s) — game just pauses when it expires

**Gate:** You can hover over asteroids, they break, currency increments, timer ends.

### Phase 2 — Round Loop
- [ ] UpgradeShop scene (placeholder UI, just a "Next Round" button)
- [ ] Main.gd scene transitions between GameWorld and UpgradeShop
- [ ] GameState tracks currency across rounds
- [ ] Object spawner: spawns N asteroids at round start, respawns on death up to max count

**Gate:** Full round loop — play, earn, press next round, play again.

### Phase 3 — Black Hole Growth
- [ ] Mass tracking separate from currency
- [ ] BlackHole visual scales through 3 stages (expand to 10 later)
- [ ] Mass threshold system in GameState
- [ ] HUD mass progress bar

**Gate:** Black hole visibly grows when enough mass is collected.

### Phase 4 — Upgrade Tree (Core)
- [ ] `UpgradeData` resource class
- [ ] `upgrades.json` with 10–15 starter nodes
- [ ] UpgradeManager loads and parses tree
- [ ] UpgradeShop renders nodes with prerequisite locking
- [ ] Purchase logic: deduct currency, unlock, apply effect via UpgradeManager
- [ ] Effects: breaker_damage, breaker_radius, attack_speed, object_value

**Gate:** Can buy upgrades, see effects reflected in next round.

### Phase 5 — Object Variety
- [ ] Dense Rock, Planet, Star (using ObjectData resource)
- [ ] Weighted spawner: spawn distribution based on black hole stage
- [ ] Health bars on objects (visible depletion)
- [ ] Hit audio/visual feedback

**Gate:** Multiple object types appear, harder ones spawn later.

### Phase 6 — Special Types
- [ ] Electric asteroid: chain lightning on death (Area2D sweep, apply damage to neighbors)
- [ ] Radioactive asteroid: AoE damage cloud on death (timer-based, damages overlapping objects)
- [ ] Both locked behind upgrades

**Gate:** Special types function correctly and feel satisfying.

### Phase 7 — Polish
- [ ] Upgrade tree visual layout (node graph UI)
- [ ] Black hole all 10 stages with distinct visuals
- [ ] Screen shake on stage growth
- [ ] Ambient space background (parallax or shader)
- [ ] Audio: break sounds, background music, UI sounds
- [ ] Main menu and settings (resolution, volume)

---

## Known Design Traps to Avoid

**Don't build the upgrade UI before the upgrade data system.** The UI depends on the data model. Build UpgradeManager + JSON first, then render it.

**Don't use AnimationPlayer for orbit paths.** Use code-driven circular motion (`cos/sin` of elapsed time) so orbit speed can be modified by upgrades at runtime.

**Don't make objects Area2D.** Objects should be `CharacterBody2D` or `Node2D` with a child `Area2D` for hit detection. Keeps physics and logic separated.

**Don't couple damage to frame rate.** Breaker damage fires on a `Timer` node, not in `_process()`. Frame rate independence matters.

**Don't add a second game mode until the first is complete and fun.** The reference game has multiple modes. You don't. Finish the main loop first.

---

## Balancing Notes (Starting Values)

These are guesses. Tune them once Phase 4 is working.

| Parameter             | Starting Value |
|-----------------------|---------------|
| Round duration        | 30 seconds    |
| Breaker attack speed  | 0.5s interval |
| Breaker base damage   | 10            |
| Breaker base radius   | 40px          |
| Asteroid base HP      | 30            |
| Asteroid base value   | 1             |
| Max objects on screen | 12            |
| Mass per asteroid     | 5             |
| Stage 2 mass threshold| 100           |

---

## What Claude Code Should NOT Do

- Do not refactor working code unless a phase is complete and a specific problem is identified
- Do not add new scenes without updating this document's structure section
- Do not add dependencies or plugins without explicit instruction
- Do not generate placeholder assets — use Godot primitives (ColorRect, Circle draw) until real assets exist
- Do not implement save/load to disk until Phase 4 is complete — GameState can be in-memory only during early development

---

## Git Workflow

After completing any task or phase gate, run:
1. `git add .`
2. `git commit -m "descriptive message of what was built"`
3. `git push`

Commit messages should reference the phase and what was completed.
Example: "Phase 1 - asteroid orbit and breaker damage working"
Do not commit broken or mid-feature code.