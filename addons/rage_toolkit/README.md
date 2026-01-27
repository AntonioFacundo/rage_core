# Rage Toolkit (Godot 4.x)

Rage Toolkit is an optional editor/CLI layer for Rage Core.
It provides scaffolding UI and the `rage.py` CLI to generate mods, packs, and scenes.

## Plugin Setup

1) Copy `addons/rage_toolkit/` into your project.
2) Enable **Rage Toolkit** in Project Settings -> Plugins.

Note: Replay mode is configured in **Rage Core** (see `addons/rage_core/README.md`).
Note: Game-specific code lives in `game/` and the project kernel should be `res://game/game_kernel.gd`.

## CLI

See `CLI.md` for commands.

## Tutorial

See `TUTORIAL.md` for a step-by-step setup guide.

## No-Code Tutorial

See `TUTORIAL_NO_CODE.md` for a guided flow with simulated screenshots.

Spanish version:
- `TUTORIAL_NO_CODE_ES.md`

Printable version:
- `TUTORIAL_NO_CODE_PRINT.md`

## Rapid Game Prototyping Workflow

1) Create a base scaffold
```bash
python rage.py project:init --scene
```

2) Create a focused game pack
```bash
python rage.py game:new my_game --template platformer_basic --scene
```

3) Add content quickly
```bash
python rage.py pickup:new pickup_speed --mod my_game --scene
python rage.py enemy:new enemy_small --mod my_game --ai patrol --scene
```

4) Use Godot to place scenes, add collisions, and tweak visuals.

## Kernel Structure (Current)

- `addons/rage_core/` is the frozen framework.
- `game/` is project-specific code.
- Your project autoload should be `Kernel="*res://game/game_kernel.gd"`.

## Godot UI Checklist

- Create input actions: `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `ability_primary`.
- Ensure your player scene has a `CharacterBody2D` + `CollisionShape2D`.
- Attach `PlayerBodyBridge` to the player node.
- Create a `StaticBody2D` floor with a collider.
- For pickups/ladder/surfaces, place `Area2D` nodes and attach `Trigger2DBridge`.
- For combat, add an `Area2D` hitbox and attach `Hitbox2DBridge`.
- Add `Camera2DController` and set `target_path` to the player if you want smoothing/look-ahead.

## Scaffold Dock

Enable **Rage Toolkit** and open the **Rage Core Scaffold** dock to generate files
without touching code.

## Quick Wizard (No-Code)

Use the **Quick Wizard** section in the dock to generate:
- a base mod + pack
- a simple pickup
- optional floor/player in a scene
