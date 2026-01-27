# Rage Core CLI (rage.py)

This CLI generates scaffolds for mods and content packs.

## Quick Start

```bash
python rage.py --root . mod:new base
python rage.py --root . pack:new base
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

### game:new

Create a game scaffold with a template.

Templates:
- `custom`
- `platformer_basic` (player + floor + speed pickup)
- `melee_platformer` (platformer_basic + small enemy)
- `runner_basic` (ice surface + fast movement)
- `arena_basic` (enemy chase)

```bash
python rage.py game:new <id> [--template custom|platformer_basic|melee_platformer] [--scene] [--force]
```

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

## Notes

- Mods and packs are available at `res://mods` and `res://data_packs`.
- They are only loaded when your game kernel calls `_load_mods()` and `_load_content_packs()`.
- Generated scenes are minimal stubs; add collisions/sprites in Godot.

