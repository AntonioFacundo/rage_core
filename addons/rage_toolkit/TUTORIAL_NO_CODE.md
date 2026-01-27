# Rage Toolkit: No-Code Tutorial (Simulated Screenshots)

This guide shows how to build a tiny playable prototype without writing code.
Screenshots are simulated to match the UI you will see.

## 0) Enable Plugins

Open **Project Settings → Plugins** and enable:
- Rage Core
- Rage Toolkit

```
┌────────────────────────── Plugins ──────────────────────────┐
│ [✓] Rage Core        Enabled                               │
│ [✓] Rage Toolkit     Enabled                               │
└─────────────────────────────────────────────────────────────┘
```

## 1) Open the Scaffold Dock

Open the **Rage Core Scaffold** dock (right side).

```
┌──────────────────── Rage Core Scaffold ─────────────────────┐
│ Project Init     [Create Base]                              │
│ Mod + Pack       [mod_id ______] [Create Scene] [Create]    │
│ Game Template    [game_id ___] [template v] [Scene] [Go]    │
│ Pickup           [pickup_id][mod_id][Pick Sprite][Pick Sfx] │
│ Enemy            [enemy_id][mod_id][AI v][Scene][Create]    │
│ Surface          [surface_id][mod_id][speed][accel][decel]  │
│ Ladder           [ladder_id][mod_id][Scene][Create]         │
│ Quick Wizard     [game_id][scenes/main.tscn][Create]        │
│ Scene Tools      [scenes/main.tscn][Pick][Add Floor][Add P] │
│ Status: Ready.                                              │
└─────────────────────────────────────────────────────────────┘
```

## 2) Create a Simple Game (Wizard)

In **Quick Wizard**:
- game_id: `my_game`
- scene: `scenes/main.tscn`
- click **Create Simple Game**

```
Quick Wizard:
[game_id: my_game] [scenes/main.tscn] [Create Simple Game]
```

Result:
- Creates `mods/my_game/` and `data_packs/my_game.json`
- Creates `scenes/my_game/main.tscn`
- Adds a basic pickup template
- Adds floor/player nodes if the scene path is valid

## 3) Add Colliders (Godot UI)

Open `scenes/my_game/main.tscn` and add:
- **CollisionShape2D** under Player
- **CollisionShape2D** under Floor

```
Main
 ├─ Player (CharacterBody2D)
 │   └─ CollisionShape2D  ← add shape
 └─ Floor (StaticBody2D)
     └─ CollisionShape2D  ← add shape
```

## 4) Create a Pickup

In the dock:
- pickup_id: `pickup_speed`
- mod_id: `my_game`
- pick a sprite (optional)
- pick a sound (optional)
- Create Scene (checked)
- Click **Create Pickup**

```
Pickup:
[pickup_speed] [my_game] [Pick Sprite] [Pick Sfx] [✓ Scene] [Create Pickup]
```

Result:
- Adds a pickup entry to `data_packs/my_game.json`
- Creates `scenes/pickups/pickup_speed.tscn`

## 5) Place the Pickup in the Scene

Drag `scenes/pickups/pickup_speed.tscn` into your main scene.
Place it above the floor.

```
Main
 ├─ Player
 ├─ Floor
 └─ pickup_speed (Area2D)
```

## 6) Configure Input Actions

In **Project Settings → Input Map**, add:
- move_left
- move_right
- move_up
- move_down
- jump
- ability_primary

Bind keys you want (A/D, arrows, etc.).

## 7) Play

Press **Play**. Your character can move, and touching the pickup triggers its effect.

## Troubleshooting

- Player not moving: check Input Map actions.
- No collisions: ensure CollisionShape2D has a shape assigned.
- Pickup not triggering: ensure Area2D has a CollisionShape2D and is placed in the scene.

