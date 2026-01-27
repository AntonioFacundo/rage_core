# Mods Tests: Engine-agnostic verification for mod loader determinism.
class_name ModTestRunner

static func run_all() -> Dictionary:
	var errors: Array = []
	var total := 0
	_test_mod_order(errors)
	total += 2
	return {
		"errors": errors,
		"total": total
	}

static func _test_mod_order(errors: Array) -> void:
	var m_a := _make_manifest("mod.a", {}, 0)
	var m_b := _make_manifest("mod.b", {"mod.a": "^1.0.0"}, 0)
	var m_c := _make_manifest("mod.c", {}, 0)
	var loader := ModLoader.new()
	var res := loader.resolve_order([m_b, m_c, m_a])
	_assert(res.ok, "ModLoader.resolve_order should succeed", errors)
	if res.ok:
		var ordered := []
		for m in res.value:
			ordered.append(m.id)
		var expected := ["mod.a", "mod.b", "mod.c"]
		_assert(ordered == expected, "ModLoader resolve order should be deterministic", errors)

static func _make_manifest(mod_id: String, deps: Dictionary, hint: int) -> ModManifest:
	var data := {
		"id": mod_id,
		"version": "1.0.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": deps,
		"load_order_hint": hint
	}
	var result := ModManifest.from_dict(data)
	return result.value

static func _assert(condition: bool, message: String, errors: Array) -> void:
	if not condition:
		errors.append(message)
