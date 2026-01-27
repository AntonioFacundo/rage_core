# Replay Mode (Rage Core)

This document describes deterministic replay recording and verification.

## Overview
- Replay mode records per-tick input frames and state hashes.
- Replays are deterministic when using the same seed, mod set, and input stream.

## Seed system
- `seed8` is an 8-character Base36 string (0-9, A-Z).
- `seed64` is derived from `seed8` using FNV-1a 64-bit.
- Kernel always seeds the deterministic RNG before simulation ticks.

## ProjectSettings
- `rage_core/replay/mode` = `live` | `record` | `replay`
- `rage_core/replay/path` = replay file path
- `rage_core/replay/seed8` = seed string for live/record
- `rage_core/replay/tick_rate` = fixed tick rate (default 60)
- `rage_core/replay/max_ticks_per_frame` = accumulator cap (default 5)

## Record a replay
1) Set `rage_core/replay/mode = record`.
2) Set `rage_core/replay/path` (e.g. `user://rage_replay.rage_replay.json`).
3) Optional: set `rage_core/replay/seed8`.
4) Run the game. On exit, a `.json` replay will be written.

## Replay and verify
1) Set `rage_core/replay/mode = replay`.
2) Set `rage_core/replay/path` to the recorded file.
3) Run the game. The kernel compares per-tick hashes.
4) On mismatch, it logs the first failing tick and writes:
   `user://rage_desync_tick_<n>.json`.

## Replay file format
- `metadata` includes:
  - version, game_id, seed8, seed64, tick_rate, mods
  - hashes: array of `[tick_index, hash]`
- `frames` is an array of:
  - `tick`, `actions` ([id, pressed]), `axes` ([id, value])

## Regression test harness
Use the provided scene:
`res://addons/rage_core/scenes/replay_regression_test.tscn`

Behavior:
- Runs a fixed synthetic input pattern for `TICKS_TARGET`.
- Records a replay, then replays it and verifies hashes.
- Prints `REPLAY REGRESSION PASS` on success.
