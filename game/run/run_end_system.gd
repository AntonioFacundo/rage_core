# Game: Deterministic run end handling and reset. Allowed deps: core types only.
class_name RunEndSystem
extends SimulationStep

const RESULT_KEYS := ["reward_npc_id", "reward_leaf_id", "currency", "run_health", "abilities"]

var _run_state: RunState
var _auto_reset: bool = true

func _init(run_state: RunState, auto_reset: bool) -> void:
	_run_state = run_state
	_auto_reset = auto_reset

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return

	if _run_state.is_run_end_pending_reset():
		_reset_run(context)
		return

	if _run_state.is_run_active():
		return

	if _run_state.get_run_end_reason() != "":
		return

	var reason := _run_state.get_end_reason()
	if reason == "":
		return

	var result := _build_result(reason)
	_run_state.set_run_end_reason(reason)
	_run_state.set_run_end_data(result)
	if _auto_reset:
		_run_state.set_run_end_pending_reset(true)

	context.logger.info("[RUN] end reason=" + reason)
	context.logger.info("[RUN] result=" + _format_result(result))

func _build_result(reason: String) -> Dictionary:
	return {
		"reason": reason,
		"reward_npc_id": _run_state.get_reward_npc_id(),
		"reward_leaf_id": _run_state.get_reward_leaf_id(),
		"currency": _run_state.get_currency(),
		"run_health": _run_state.get_run_health(),
		"abilities": _run_state.list_abilities()
	}

func _format_result(result: Dictionary) -> String:
	var parts: Array = []
	for key in RESULT_KEYS:
		if result.has(key):
			parts.append(key + "=" + str(result[key]))
	return "{" + ",".join(parts) + "}"

func _reset_run(context: SimulationContext) -> void:
	var next_seed := _next_seed(_run_state.get_seed64())
	_run_state.reset(next_seed)
	_run_state.set_run_end_pending_reset(false)
	_run_state.set_run_end_reason("")
	_run_state.set_run_end_data({})
	_run_state.set_room_status("")
	_run_state.set_tower_stage("rooms")
	_run_state.set_gate_status("inactive")
	_run_state.set_boss_status("inactive")
	context.logger.info("[RUN] reset next_seed=" + str(next_seed))

func _next_seed(seed64: int) -> int:
	return Fnv1a64.hash_string(str(seed64) + "|run")
