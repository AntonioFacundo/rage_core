# Rage Core (Godot 4.x)

This repository now includes a complete layered architecture skeleton under `addons/rage_core/`.
It is engine-agnostic at the core/game layers, with a strict mod API, deterministic mod loading,
and a kernel that assembles everything. The goal is to let a finished game remain stable while
adding content and mechanics through mods. Replay mode is included for deterministic regression testing.

Rage Core is a plugin. Project-specific code lives outside the plugin (for example in `res://game/`),
including the project kernel that decides what systems, inputs, and content are enabled.

## 1) Overview

Why layers:
- Prevent engine leakage into core logic.
- Keep game rules deterministic and testable.
- Allow content to evolve via mods without changing base code.

Goals:
- Engine-agnostic core (no Godot classes/singletons).
- Game core isolated, deterministic, and testable.
- Mods with stable, versioned API and validated dependencies.
- Godot adapters fully encapsulated.
- Kernel runs the loop and assembles everything.
- Replay mode with per-tick hash verification.

## 2) Dependency Diagram

```
presentation -> kernel -> (mods, game, platform) -> core
```

Rules:
- core/ and game/ never depend on Godot APIs.
- mods/ only talk to GameAPI.
- platform/godot/ contains the only Godot integration.

## Documentation Map

Start here:
- `addons/rage_core/README.md` (this file)
- `addons/rage_core/docs/REPLAY.md` (replay + determinism)
- `addons/rage_core/docs/TESTS.md` (core tests)

Guides:
- `addons/rage_toolkit/TUTORIAL.md` (step-by-step 2D setup)
- `addons/rage_toolkit/CLI.md` (scaffolding commands)
- `addons/rage_toolkit/README.md` (toolkit overview)

Design notes (optional):
- `design/GDD.md`
- `design/ENDINGS_RULES.md`

## 3) Folder Structure (addons/rage_core/)

- core/
  - version.gd (CORE_VERSION)
  - errors.gd
  - event_bus.gd
  - types/ (result.gd, option.gd, ids.gd, event_base.gd)
  - interfaces/ (i_logger.gd, i_file_store.gd, i_input_source.gd, i_clock.gd)
- platform/godot/
  - godot_logger.gd
  - godot_file_store.gd
  - godot_input_source.gd
  - godot_clock.gd
  - godot_save_store.gd
  - godot_physics_2d.gd
  - godot_combat_sensor_2d.gd
  - godot_trigger_sensor_2d.gd
- game/
  - version.gd (GAME_VERSION)
  - constants.gd (event ids, command ids, tags)
  - game_core.gd (no Godot)
  - game_api.gd (mods facade)
  - game_state.gd
  - pipeline/ (simulation_step.gd, systems/)
    - simulation_context.gd
    - simulation_pipeline.gd
    - systems/movement_2d_system.gd
    - systems/combat_system.gd
    - systems/pickup_system.gd
    - systems/player_input_system.gd
    - systems/ai_system.gd
    - systems/surface_system.gd
    - systems/ladder_system.gd
    - systems/trigger_buffer_system.gd
  - ai/ (ai_config.gd)
  - input/ (input_registry.gd, input_map.gd, input_snapshot.gd)
  - content/ (content_def.gd, content_registry.gd)
  - save/ (save_schema.gd, save_manager.gd)
  - commands/ (attack_command.gd, move_command.gd)
  - events/ (damage_event.gd, room_event.gd, pickup_event.gd)
- mods/
  - semver.gd
  - mod_manifest.gd
  - mod_base.gd
  - mod_loader.gd
  - example_mod_double_damage.gd (reference only)
  - example_mod_movement_tuning.gd (reference only)
  - example_mod_pickup_speed.gd (reference only)
- data_packs/ (json content packs, example_pack.json)
- kernel/
  - game_kernel.gd (base kernel; project kernel extends this)
- presentation/
  - debug_listener.gd
  - player_body_bridge.gd
  - hitbox_2d_bridge.gd
  - trigger_2d_bridge.gd
  - camera_2d_controller.gd
  - hud_controller.gd
  - moving_platform_bridge.gd
  - one_way_platform_bridge.gd

## 4) Stability Contract for Mods

Stable APIs:
- GameAPI facade (subscribe/emit/apply_damage, read-only state, logger, clock).
- GameConstants event ids and schemas (DamageEvent).
- Mod manifest schema (id, version, requires_core, requires_game, deps).

May change without breaking mods:
- Internal game systems, pipelines, and state storage.
- Presentation and platform adapters.

Versioning:
- Core and game versions are semver.
- Mods declare `requires_core` and `requires_game`.
- Loader enforces constraints and dependency versions.

## 5) EventBus Details

Features:
- subscribe/unsubscribe with tokens
- priority (higher first)
- cancellation (stop propagation)
- intercept mode (mutate payload before others)

Order:
- intercept handlers first
- then by priority desc
- then by registration order

All events validate their payload schema before and after intercept.

## 6) How to Write a Mod (Step by Step)

1) Create a class that extends `ModBase`.
2) Provide a valid `ModManifest`.
3) Implement `on_load(api)` and subscribe to events.
4) Use only the GameAPI (no platform/presentation access).

Example (see `mods/example_mod_double_damage.gd`):
- Intercepts `DamageEvent` and doubles `amount`.
- Logs action via `api.get_logger()`.

Where to put game logic:
- Core rules and commands live in `game/game_core.gd`.
- Deterministic systems live in `game/pipeline/systems/`.
- Mods extend behavior without touching engine code.

## 7) How Mods are Loaded

Current flow (in `kernel/game_kernel.gd` when invoked by the project kernel):
- Instantiate mod classes.
- Collect manifests.
- Validate versions and dependencies.
- Deterministically order mods.
- Call `on_load()` in order.

Validation rules:
- required core/game versions per mod
- dependency existence + version constraints
- cycle detection in dependency graph
- deterministic order (dep order, load_order_hint, id)

TODO:
- File-based mod discovery
- Hot reload
- Data patching

## 8) Minimal Example (Godot)

1) Add `res://game/game_kernel.gd` as Autoload.
2) (Optional) Add `addons/rage_core/presentation/debug_listener.gd` to a scene
   and point it to the kernel node.
3) Enable systems you want in `game/game_kernel.gd`, then run the project.

Project kernel responsibilities (in `res://game/game_kernel.gd`):
- bind inputs (optional)
- register systems into the pipeline (optional)
- load content packs and mods (optional)

## 8.1) Tutorial

See `addons/rage_toolkit/TUTORIAL.md` for a step-by-step 2D setup guide.

## 8.2) Replay Mode (Determinism)

Replay supports deterministic input capture and per-tick hash verification.
See `addons/rage_core/docs/REPLAY.md` for details.

Quick settings (ProjectSettings):
- `rage_core/replay/mode` = live | record | replay
- `rage_core/replay/path` = `user://rage_replay.rage_replay.json`
- `rage_core/replay/seed8` = 8-char Base36 seed
- `rage_core/replay/tick_rate` = fixed tick rate

Editor shortcut:
- **Rage Core -> Replay Mode: Live/Record/Replay**

## 8.3) Regression Test Scene

Run `res://addons/rage_core/scenes/replay_regression_test.tscn` to record + replay
with a synthetic input pattern. It prints `REPLAY REGRESSION PASS` on success.

## 8.2) Optional Toolkit

Rage Toolkit is an optional addon that provides the scaffolding UI and CLI.
See `addons/rage_toolkit/README.md` for setup and commands.

## 8.3) Godot UI Checklist

- Create input actions: `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `ability_primary`.
- Ensure your player scene has a `CharacterBody2D` + `CollisionShape2D`.
- Attach `PlayerBodyBridge` to the player node.
- Create a `StaticBody2D` floor with a collider.
- For pickups/ladder/surfaces, place `Area2D` nodes and attach `Trigger2DBridge`.
- For combat, add an `Area2D` hitbox and attach `Hitbox2DBridge`.
- Add `Camera2DController` and set `target_path` to the player if you want smoothing/look-ahead.

## 9) Scaffold Dock (Toolkit)

Enable **Rage Toolkit** and open the **Rage Core Scaffold** dock to generate files
without touching code.

## 9) Roadmap

- Add tests for core types and mod loader
- Hot-reload mod scripts and data
- Extend input and persistence adapters
- Add data patches for commands/events
- Build room/level flow as pure game systems
- Add Movement2D module and pipeline scheduler
- Add content registry and save/load schemas

## 10) 2D-Ready Module Extensions

These are new contracts to make the core reusable for 2D games:

- InputRegistry/GameInputMap/InputSnapshot: maps stable action ids to engine inputs and produces a deterministic snapshot.
- ContentRegistry: lets mods register content definitions (items, pickups, enemies, rooms, sprites, sounds).
- SaveStore (ISaveStore): abstracts persistence with JSON payloads.
- Physics2D (IPhysics2D): adapter boundary for collision/motion resolution.
- Movement2D types: config/input/state/contracts used by movement systems.
- CombatSensor2D (ICombatSensor2D): adapter boundary for hit events.
- TriggerSensor2D (ITriggerSensor2D): adapter boundary for pickups/triggers.
- AIConfig: reusable patrol/chase config for simple enemies.
- SurfaceSystem: applies movement multipliers based on surface triggers.
- LadderSystem: toggles climb mode via triggers.

The core/game layers still contain no Godot usage. All engine calls live in platform/godot.

## 11) Using the Movement2D System

1) Register a body in the platform adapter:
   - In Godot, attach `PlayerBodyBridge` to a `CharacterBody2D` and set `body_id` to `player`.
   - Or call `Kernel.register_body("player", player_body)` manually.
2) Register the entity in the system:
   - `Movement2DSystem.register_entity("player")` (wire this in your game kernel).
3) Bind actions/axes if needed:
   - `GameAPI.bind_action(GameConstants.ACTION_JUMP, "jump")`
   - `GameAPI.bind_axis(GameConstants.AXIS_MOVE_X, "move_x")`
4) The kernel samples input every frame and runs the pipeline.

Note: `GodotInputSource.get_axis` is a stub (returns 0). Axis support is a TODO; movement falls back to action left/right.

TODO: expose a small helper for registering entities from the scene.


