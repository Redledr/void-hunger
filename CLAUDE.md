# CLAUDE.md — Black Hole Incremental (Godot 4.4)

## Project Overview
A 2D incremental game. A black hole sits at the center. Objects drift toward it, get consumed, and increase its mass. Player buys upgrades to attract more and better objects.

---

## CRITICAL: No .tscn Files
**Do not create or edit .tscn files. Ever.**
All scenes are built in GDScript using `new()` and `add_child()`.
The only .tscn file allowed is `Main.tscn` which is created once manually by the developer.
If a node needs to exist, create it in code.

---

## Tech Stack
- **Engine:** Godot 4.4
- **Language:** GDScript only
- **Scenes:** Built in code, not in the editor
- **Target:** Desktop

---

## Project Structure
```
res://
├── Main.tscn              # Created manually once — just a Node2D with main.gd attached
├── scripts/
│   ├── main.gd            # Spawns objects, holds the scene together
│   ├── black_hole.gd      # Black hole node, created in main.gd
│   ├── space_object.gd    # Moving objects, created in main.gd
│   ├── ui.gd              # HUD, created in main.gd
│   └── game_state.gd      # Autoload — the only one
└── assets/
    └── sprites/
```

---

## How to Build Nodes in Code

Always do it this way:

```gdscript
var bh = Node2D.new()
bh.set_script(load("res://scripts/black_hole.gd"))
add_child(bh)
```

Never reference nodes by hardcoded path strings like `get_node("../BlackHole")`.
Store references as variables instead:

```gdscript
var black_hole
var ui

func _ready():
    black_hole = Node2D.new()
    black_hole.set_script(load("res://scripts/black_hole.gd"))
    add_child(black_hole)

    ui = CanvasLayer.new()
    ui.set_script(load("res://scripts/ui.gd"))
    add_child(ui)
```

---

## Autoload Setup
Add this in Project Settings > Autoload:
- Name: `GameState`
- Path: `res://scripts/game_state.gd`

`GameState` holds all numbers. Every other script reads from it.

---

## game_state.gd
```gdscript
extends Node

var mass = 0.0
var spawn_level = 0
var pull_level = 0
var multi_level = 0

signal mass_changed

func add_mass(amount):
    mass += amount
    emit_signal("mass_changed")

func upgrade_cost(base, level):
    return base * pow(1.15, level)

func buy_upgrade(which):
    var costs = {"spawn": 10.0, "pull": 15.0, "multi": 25.0}
    var cost = upgrade_cost(costs[which], get(which + "_level"))
    if mass >= cost:
        mass -= cost
        set(which + "_level", get(which + "_level") + 1)
        emit_signal("mass_changed")
```

---

## Coding Rules

- Short functions — if it is more than 20 lines, split it
- No clever one-liners
- Plain variable names: `speed`, `mass`, `target`, `timer`
- No comments or documentation in scripts
- Use `@export` for any number that might need tuning

**Movement:**
```gdscript
func _process(delta):
    var direction = (target_pos - position).normalized()
    position += direction * speed * delta
```

**Collision via distance check:**
```gdscript
func _process(delta):
    if position.distance_to(target_pos) < 20.0:
        GameState.add_mass(mass_value)
        queue_free()
```

---

## Spawning Objects

```gdscript
var spawn_timer

func _ready():
    spawn_timer = Timer.new()
    spawn_timer.wait_time = 2.0
    spawn_timer.connect("timeout", _spawn_object)
    add_child(spawn_timer)
    spawn_timer.start()

func _spawn_object():
    var obj = Node2D.new()
    obj.set_script(load("res://scripts/space_object.gd"))
    add_child(obj)
```

---

## Object Types
| Type | Mass Value | Notes |
|---|---|---|
| Asteroid | 1.0 | Default, always spawning |
| Planet | 10.0 | Unlocked at pull level 3 |
| Star | 100.0 | Unlocked at pull level 6 |
| Neutron Star | 1000.0 | Unlocked at pull level 10 |

---

## Upgrade Effects
| Upgrade | Effect |
|---|---|
| Spawn Rate | `spawn_timer.wait_time = max(0.3, 2.0 - spawn_level * 0.15)` |
| Pull Strength | Increases `speed` on all new objects |
| Multiplier | `mass_value *= 1 + (multi_level * 0.25)` |

---

## Visual Style
- Background: dark (`#0a0a14`) — set in Project Settings > Rendering > Background Color
- Black hole: `ColorRect` or `Sprite2D`, dark circle, grows slightly with mass
- Objects: small `ColorRect` nodes of different colors per type
- UI: `Label` nodes for mass, `Button` nodes for upgrades

---

## Start Here
1. Create `Main.tscn` manually — just a `Node2D` with `main.gd` attached
2. Write `game_state.gd` and add it as Autoload
3. Write `main.gd` — get a Timer spawning objects
4. Write `space_object.gd` — move toward center, disappear on arrival
5. Verify mass is increasing in `GameState`
6. Add UI last
