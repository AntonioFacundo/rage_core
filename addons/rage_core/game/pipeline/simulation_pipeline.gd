# Game: Ordered simulation pipeline. Allowed deps: core types + game types.
class_name SimulationPipeline

var _steps := []
var _seq_counter: int = 0
var _phase_order := {}

func register_step(phase_id: String, priority: int, step: SimulationStep) -> Result:
	if not GameConstants.PHASE_IDS.has(phase_id):
		return Result.err_result("Unknown phase id: " + phase_id)
	if step == null or not (step is SimulationStep):
		return Result.err_result("Invalid simulation step")
	_seq_counter += 1
	_steps.append({
		"phase": phase_id,
		"priority": priority,
		"step": step,
		"seq": _seq_counter
	})
	return Result.ok_result(true)

func clear() -> void:
	_steps.clear()
	_seq_counter = 0

func run(context: SimulationContext, delta: float) -> void:
	_ensure_phase_order()
	_steps.sort_custom(_step_before)
	for entry in _steps:
		var step: SimulationStep = entry["step"]
		step.run(context, delta)

func _step_before(a, b) -> bool:
	if a["phase"] != b["phase"]:
		return int(_phase_order[a["phase"]]) < int(_phase_order[b["phase"]])
	if a["priority"] != b["priority"]:
		return a["priority"] > b["priority"]
	return int(a["seq"]) < int(b["seq"])

func get_ordered_steps_debug() -> Array:
	_ensure_phase_order()
	var snapshot := _steps.duplicate()
	snapshot.sort_custom(_step_before)
	var out: Array = []
	for entry in snapshot:
		out.append({
			"phase": entry["phase"],
			"priority": entry["priority"],
			"seq": entry["seq"],
			"step": entry["step"]
		})
	return out

func _ensure_phase_order() -> void:
	if _phase_order.size() > 0:
		return
	for i in range(GameConstants.PHASE_IDS.size()):
		_phase_order[GameConstants.PHASE_IDS[i]] = i
