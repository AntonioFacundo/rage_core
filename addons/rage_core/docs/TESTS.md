# Core Tests (Engine-Agnostic)

Rage Core includes engine-agnostic tests for core/game/mods logic.
They do not depend on Godot APIs and can be invoked from any script.

## Test runners
- `addons/rage_core/core/tests/core_test_runner.gd`
- `addons/rage_core/game/tests/game_test_runner.gd`
- `addons/rage_core/mods/tests/mod_test_runner.gd`
- `addons/rage_core/tests/rage_core_tests.gd` (aggregate)
- `addons/rage_core/tests/layer_guard_runner.gd` (Godot-dependent layer guard)

## How to run (manual)
Create a small temporary script and call the aggregate runner:

```gdscript
var result := RageCoreTests.run_all()
print(result)
```

Expected output:
- `ok = true` and an empty `errors` array.

Notes:
- This avoids modifying kernel or platform code.
- Layer guard uses Godot file APIs to scan for forbidden tokens in core/game.
- You can delete the temporary script after running.
