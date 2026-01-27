# Rage Toolkit: No-Code Tutorial (Printable)

Goal: build a tiny playable prototype without writing code.

Checklist:
- Enable Rage Core + Rage Toolkit plugins.
- Open Rage Core Scaffold dock.
- Use Quick Wizard to create a game.
- Add collisions to player + floor.
- Create a pickup and place it in the scene.
- Configure Input Map actions.
- Press Play.

Steps:
1) Plugins
   - Project Settings → Plugins → enable Rage Core + Rage Toolkit.

2) Quick Wizard
   - game_id: my_game
   - scene: scenes/main.tscn
   - Click Create Simple Game

3) Collisions
   - Player: add CollisionShape2D
   - Floor: add CollisionShape2D

4) Pickup
   - pickup_id: pickup_speed
   - mod_id: my_game
   - Create Scene: enabled
   - Click Create Pickup
   - Drag pickup scene into main

5) Inputs
   - move_left, move_right, move_up, move_down, jump, ability_primary

6) Play
   - Press Play and test.
