# Tests: Aggregate test runner for core/game/mods + layer guard.
class_name RageCoreTests

static func run_all() -> Dictionary:
	var errors: Array = []
	var total := 0
	var core_res := CoreTestRunner.run_all()
	var game_res := GameTestRunner.run_all()
	var mod_res := ModTestRunner.run_all()
	var guard_res := LayerGuardRunner.run_all()
	errors.append_array(core_res["errors"])
	errors.append_array(game_res["errors"])
	errors.append_array(mod_res["errors"])
	errors.append_array(guard_res["errors"])
	total += int(core_res["total"])
	total += int(game_res["total"])
	total += int(mod_res["total"])
	total += int(guard_res["total"])
	var failed := errors.size()
	var passed := total - failed
	var pct := 100.0
	if total > 0:
		pct = float(passed) / float(total) * 100.0
	return {
		"ok": failed == 0,
		"errors": errors,
		"total": total,
		"passed": passed,
		"failed": failed,
		"percent": pct
	}
