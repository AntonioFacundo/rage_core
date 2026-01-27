# Rage Core CLI (rage.py)

This CLI generates scaffolds for mods and content packs.

**Location:** `addons/rage_toolkit/rage.py`

## Quick Start

```bash
python addons/rage_toolkit/rage.py --root . mod:new base
python addons/rage_toolkit/rage.py --root . pack:new base
```

Or from project root (if in PATH):
```bash
python rage.py --root . mod:new base
```

## Commands

### project:init

Create the base structure for a game project (mods + packs).

```bash
python rage.py project:init [--mod base] [--pack base] [--scene] [--force]
```

### mod:new

Create a mod scaffold.

```bash
python rage.py mod:new <id> [--version X.Y.Z] [--requires-core ^1.0.0] [--requires-game ^1.0.0] [--deps id@^1.0.0] [--order N] [--description TEXT] [--force]
```

Example:

```bash
python rage.py mod:new base --description "Base game mod"
```

### pack:new

Create a content pack JSON.

```bash
python rage.py pack:new <id> [--force]
```

### modpack:new

Create a mod + pack with the same id.

```bash
python rage.py modpack:new <id> [--version X.Y.Z] [--requires-core ^1.0.0] [--requires-game ^1.0.0] [--order N] [--scene] [--force]
```

### pickup:new

Create a pickup mod + pack entry.

```bash
python rage.py pickup:new <id> --mod <mod_id> [--scene] [--force]
```

### enemy:new

Create an enemy mod + pack entry.

```bash
python rage.py enemy:new <id> --mod <mod_id> [--ai idle|patrol|chase] [--scene] [--force]
```

### surface:new

Create a surface pack entry (ice/sticky/etc).

```bash
python rage.py surface:new <id> --mod <mod_id> [--max-speed-mult N] [--accel-mult N] [--decel-mult N] [--scene] [--force]
```

### ladder:new

Create a ladder pack entry.

```bash
python rage.py ladder:new <id> --mod <mod_id> [--scene] [--force]
```

### listener:new

Create an event-driven listener scaffold (uses EventBus).

```bash
python rage.py listener:new <name> --mod <mod_id> [--event game.damage] [--order N] [--force]
```

### game_system:new

Create a game system scaffold with state + api + system files.

```bash
python rage.py game_system:new <name> --mod <mod_id> [--template custom|inventory|cards|economy|progression|loot|quest] [--order N] [--force]
```

Examples:

```bash
python rage.py game_system:new inventory --mod base --template inventory
python rage.py game_system:new deck --mod base --template cards
python rage.py game_system:new shop --mod base --template economy
python rage.py game_system:new progression --mod base --template progression
python rage.py game_system:new drops --mod base --template loot
python rage.py game_system:new quests --mod base --template quest
```

### template:new

Create a game from an internal template (recommended for rapid game creation).

Internal templates include complete kernel, systems, mods, and packs:
- `arena` - Arena game with chasing enemies
- `platformer` - Platformer with movement, jumps, and pickups
- `roguelike` - Full roguelike with rooms, combat, economy, and progression
- `topdown` - Top-down game with combat and movement
- `cards` - Base structure for card games

```bash
python rage.py template:new <id> --from <template_name> [--scene] [--force]
```

Example:
```bash
python rage.py template:new my_platformer --from platformer --scene
```

### game:new

Create a game scaffold with a legacy template.

Templates:
- `custom`
- `platformer_basic` (player + floor + speed pickup)
- `melee_platformer` (platformer_basic + small enemy)
- `runner_basic` (ice surface + fast movement)
- `arena_basic` (enemy chase)

```bash
python rage.py game:new <id> [--template custom|platformer_basic|melee_platformer] [--scene] [--force]
```

**Note:** For new projects, prefer `template:new` which includes complete game setups.

### scene:add_floor

Append a basic floor node to a scene file.

```bash
python rage.py scene:add_floor --scene scenes/main.tscn
```

### scene:add_player

Append a basic player node with `PlayerBodyBridge` and a collision shape.

```bash
python rage.py scene:add_player --scene scenes/main.tscn
```

### list:mods

List detected mod scripts under `mods/`.

```bash
python rage.py list:mods
```

### list:packs

List content packs under `data_packs/`.

```bash
python rage.py list:packs
```

## New Metaprogramming Commands

These commands use the same templates as the GDScript metaprogramming tools (`dev_tools/SystemGenerator`, `dev_tools/CodeGenerator`).

### system:new

Create a game system using SystemGenerator template.

```bash
python rage.py system:new <name> [--output game/systems] [--phase phase.gameplay] [--priority 50] [--force]
```

Example:
```bash
python rage.py system:new Combat --phase phase.gameplay --priority 50
```

### event:new

Create an event using SystemGenerator template.

```bash
python rage.py event:new <name> [--event-id game.custom.id] [--output game/events] [--force]
```

Example:
```bash
python rage.py event:new DamageDealt --event-id game.combat.damage
```

### command:new

Create a command using SystemGenerator template.

```bash
python rage.py command:new <name> [--command-id cmd.custom.id] [--output game/commands] [--force]
```

Example:
```bash
python rage.py command:new Move --command-id cmd.movement.move
```

### system:complete

Create a complete system with events (CodeGenerator approach). Generates both the system and its events.

```bash
python rage.py system:complete <name> [--output game/systems] [--phase phase.gameplay] [--priority 50] [--events EVENT1 EVENT2 ...] [--force]
```

Example:
```bash
python rage.py system:complete Combat --events DamageDealt EnemyDefeated PlayerHit
```

This creates:
- `game/systems/combat_system.gd`
- `game/events/damage_dealt_event.gd`
- `game/events/enemy_defeated_event.gd`
- `game/events/player_hit_event.gd`

### generate:script

Generate a GDScript that uses CodeGenerator to create systems programmatically.

```bash
python rage.py generate:script [--output generate_systems.gd] [--force]
```

This creates a script you can run in Godot to use `CodeGenerator` and `SystemGenerator` classes.

## Notes

- Mods and packs are available at `res://mods` and `res://data_packs`.
- They are only loaded when your game kernel calls `_load_mods()` and `_load_content_packs()`.
- Generated scenes are minimal stubs; add collisions/sprites in Godot.
- New metaprogramming commands generate code compatible with `dev_tools/CodeGenerator` and `dev_tools/SystemGenerator`.
- Use `system:complete` for rapid prototyping of systems with events.

