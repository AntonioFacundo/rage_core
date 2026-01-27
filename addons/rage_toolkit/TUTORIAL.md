# Layered 2D Core Tutorial (Godot 4.x)

This tutorial walks you through building a minimal 2D prototype with the new layered core.

## 1) Create a Player Scene

1. Create a new scene with a `CharacterBody2D` root.
2. Add a `CollisionShape2D` and a simple shape (capsule/rectangle).
3. Attach `PlayerBodyBridge` to the `CharacterBody2D`.
4. Set `body_id = "player"` and keep `kernel_path = /root/Kernel`.

The bridge registers the body with the physics adapter so the core can move it.

## 2) Add a Floor

1. Create a `StaticBody2D`.
2. Add a `CollisionShape2D` and a large rectangle shape as ground.

## 3) Configure Inputs

Make sure these input actions exist (Project Settings -> Input Map):

- `move_left`
- `move_right`
- `move_up`
- `move_down`
- `jump`
- `ability_primary` (dash)

These are optional. Bind them in your game kernel by uncommenting
`_bind_default_inputs()` in `res://game/game_kernel.gd`.

## 4) Run

Press Play after enabling systems in your game kernel. If `Movement2DSystem`
is enabled, it will drive the player using:

- coyote time
- jump buffer
- jump cut
- apex gravity
- dash

## 5) Tuning Movement via Mod

Open `addons/rage_core/mods/example_mod_movement_tuning.gd` to see how a mod updates
movement settings. You can copy this pattern for other mods.

Key idea: mods call `GameAPI.set_movement_config("player", config)`.

## 6) Adding New Mechanics

To add new mechanics:

1. Create a new system by extending `SimulationStep`.
2. Register it in the pipeline:
   - `Kernel._pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, your_system)`
3. Use `InputSnapshot` and `GameState` only; do not touch Godot APIs in game/core.

## 7) Basic Combat (Hitboxes)

1. Add an `Area2D` as a child of your player.
2. Attach `Hitbox2DBridge` to that `Area2D`.
3. Set `attacker_id = "player"` and adjust `damage`/`tags`.
4. When the hitbox touches another body, it will emit a hit into the core.

Note: this is a minimal hit pipeline (no knockback yet).

## 8) Pickups (Triggers)

1. Add an `Area2D` for the pickup.
2. Attach `Trigger2DBridge` to it.
3. Set `trigger_id = "pickup.speed"` to test a speed boost.

## 9) Registering New Entities

For any new entity:

1. Call `Kernel.register_body("entity_id", character_body)`.
2. Call `Kernel.register_movement_entity("entity_id")`.

## 10) Simple Enemy AI

1. Create a `CharacterBody2D` enemy and attach `PlayerBodyBridge`.
2. Register it with `Kernel.register_body("enemy_1", enemy_body)`.
3. Create a config:
   - `var config := AIConfig.new(AIConfig.MODE_PATROL)`
   - `config.patrol_left = 100`
   - `config.patrol_right = 300`
4. Call `Kernel.register_ai_entity("enemy_1", config)`.

## 11) Camera

1. Add a `Camera2D` node to your scene.
2. Attach `Camera2DController`.
3. Set `target_path` to your player node.
4. (Optional) Enable `use_limits` and set limits in the inspector.

## 12) Save/Load

- Call `Kernel.get_api().save_state("slot_1")` to save.
- Call `Kernel.get_api().load_state("slot_1")` to load.

Note: the current schema saves health and positions only.

## 13) HUD

1. Create a `CanvasLayer` with a `Label`.
2. Attach `HUDController` to the `CanvasLayer`.
3. Set `health_label_path` to the label node.

## 14) Content Packs

Put JSON packs in `addons/rage_core/data_packs/` or `res://data_packs/`.
Load them from your game kernel by calling `_load_content_packs()`.

Example: `addons/rage_core/data_packs/example_pack.json`.

## 15) Surfaces (Ice/Sticky)

1. Create an `Area2D` that covers the surface.
2. Attach `Trigger2DBridge`.
3. Set `trigger_id = "surface.ice"`.
4. While the player stays on it, movement multipliers apply.

Note: this uses enter/exit triggers. Slopes use floor normals.

## 16) Ladders

1. Add an `Area2D` where the ladder is.
2. Attach `Trigger2DBridge`.
3. Set `trigger_id = "ladder.basic"`.
4. While inside, `move_up`/`move_down` will climb.

## 17) One-way Platforms

1. Create a `StaticBody2D` with a `CollisionShape2D`.
2. Attach `OneWayPlatformBridge`.
3. Set `collision_shape_path` to the collision shape node.

## 18) Moving Platforms

1. Create a `Node2D` platform with a child `StaticBody2D` if needed.
2. Attach `MovingPlatformBridge` to the root.
3. Set `move_axis`, `amplitude`, and `speed`.

## 19) Next Expansion Points

- Add content definitions via `ContentRegistry`.
- Add save data via `GameAPI.save_data/load_data`.
- Add event-driven gameplay via `EventBus`.

## 20) Replay & Determinism (Optional)

Rage Core can record and replay inputs deterministically.
See `addons/rage_core/docs/REPLAY.md` and use these ProjectSettings:
- `rage_core/replay/mode` = live | record | replay
- `rage_core/replay/path` = `user://rage_replay.rage_replay.json`
- `rage_core/replay/seed8` = 8-char Base36 seed

Quick editor toggle:
- **Rage Core -> Replay Mode: Live/Record/Replay**



